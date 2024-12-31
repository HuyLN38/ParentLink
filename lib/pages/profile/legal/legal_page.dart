import 'package:flutter/material.dart';
import 'package:parent_link/theme/app.theme.dart';

class LegalPage extends StatelessWidget {
  final String title;
  final String content;

  const LegalPage({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.colors.gray_light,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: Apptheme.colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Apptheme.colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Apptheme.colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Apptheme.colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildContent(content),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent(String content) {
    final paragraphs = content.split('\n\n');
    final TextStyle headerStyle = TextStyle(
      fontSize: 17,  // Slightly larger
      fontWeight: FontWeight.bold,
      color: Colors.black,  // Regular black color
    );
    final TextStyle subheaderStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );
    final TextStyle bodyStyle = TextStyle(
      fontSize: 15,
      color: Colors.black87,
      height: 1.5,
    );
    final TextStyle bulletStyle = TextStyle(
      fontSize: 15,
      color: Colors.black87,
    );

    return paragraphs.map((paragraph) {
      if (paragraph.startsWith('Team ParentLink:')) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Team ParentLink:', style: subheaderStyle),
            ),
            ...['Mr Nhat Huy', 'Mr Minh Hoang', 'Mr Minh Duc', 
                'Mr Nhu Duy', 'Mr Tuan Dat', 'Mr Tien Dat', 
                'Mr Van Giang'].map((member) => Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: bulletStyle),
                  Text(member, style: bulletStyle),
                ],
              ),
            )).toList(),
            SizedBox(height: 8),
          ],
        );
      } else if (paragraph.startsWith(RegExp(r'\d\.'))) {
        // Main section headers (1., 2., etc.)
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(paragraph, style: headerStyle),
        );
      } else if (paragraph.contains('• ')) {
        final title = paragraph.split(':\n').first;
        final items = paragraph.split(':\n').last.split('\n');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty) Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(title, style: bodyStyle),
            ),
            ...items.where((item) => item.trim().isNotEmpty).map((item) => 
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: bulletStyle),
                    Expanded(
                      child: Text(
                        item.replaceAll('• ', ''),
                        style: bulletStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
            SizedBox(height: 8),
          ],
        );
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(paragraph, style: bodyStyle),
        );
      }
    }).toList();
  }
}