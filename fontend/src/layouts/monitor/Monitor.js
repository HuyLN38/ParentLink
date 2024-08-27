import React from "react";
import TrackingPlace from "./TrackingPlace";
import SplitPane from "react-split-pane";

function Monitor() {
  return (
    <SplitPane split="vertical" minSize={50} defaultSize={100}>
      <TrackingPlace />
      
      {/* <span role="presentation" className="Resizer vertical "> </span> */}
      <div className="bg-red-400 h-screen">Pane 1</div>
    </SplitPane >
  );
}

export default Monitor;
