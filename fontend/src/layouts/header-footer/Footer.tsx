import React from "react";

function Footer(){
    return(
    <div className="container bg-gray-800 z-10 w-full mx-auto ">
        <div className="flex justify-center text-center p-3 sm:p-5 gap-x-7">
            <a href="#">
                <i className="fab fa-facebook-f text-white"></i>
            </a>
            <a href="#"> 
                <i className="fab fa-twitter text-white"></i>
            </a>
            <a href="#">
                <i className="fab fa-google text-white"></i>
            </a>
            <a href="#">
                <i className="fab fa-instagram text-white"></i>
            </a>
            <a href="#">
                <i className="fab fa-linkedin text-white"></i>

            </a>
            <a href="#">
                <i className="fab fa-github text-white"></i>
            </a>
        </div>
    </div>
    )
}
export default Footer;