import React from "react"
import { NavLink } from "react-router-dom";
function CustomerNav(){
    return(
        <div className="flex">
                <div className="flex space-x-1">
                    <NavLink to="/sign-up" className="rounded-md px-3 py-2 text-sm font-medium text-gray-300 hover:text-white ">Sign Up</NavLink>
                    <NavLink to="/sign-in" className="rounded-md px-3 py-2 text-sm font-medium text-gray-300 hover:text-white bg-[#ff8f26] hover:bg-[#ffc226] transition ease-in duration-300">Sign In</NavLink>
            </div>
        </div>
    )
}
export default CustomerNav;
