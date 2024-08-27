import React, { useEffect, useRef, useState } from "react";
import UserNav from "./userNav";
import CustomerNav from "./customerNav";
import { memoryUsage } from "process";
import { NavLink } from "react-router-dom";
function NavBar(){
    const [openBar, setOpenBar] = useState(false)
    const menuRef = useRef<HTMLDivElement>(null);
    const barRef = useRef<HTMLDivElement>(null);

    
    const toggleMenu =()=>{
        setOpenBar(!openBar);
    }

    useEffect(()=>{
        const handle = (e: MouseEvent) => {
            if (menuRef.current && !menuRef.current.contains(e.target as Node) &&
                barRef.current && !barRef.current.contains(e.target as Node)) {
                setOpenBar(false);
            }
        }
        document.addEventListener('mousedown', handle);

    })
    return(
        <div>
            <nav className="bg-gray-800 fixed z-10 w-full top-0">
                <div className="mx-auto max-w-7xl px-2 sm:px-6 lg:px-8">
                    <div className="relative flex h-16 items-center justify-between">
                        <div className="absolute inset-y-0 left-0 flex items-center sm:hidden">
                            <div ref={barRef}>
                                <button type="button" className="relative inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-gray-700 hover:text-white focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white" aria-controls="mobile-menu" aria-expanded="false" onClick={toggleMenu}>
                                    <i className="fa-solid fa-bars"></i>
                                </button>
                            </div>
                            {/* <!-- Mobile menu button--> */}

                        </div>
                        <div className="flex flex-1 items-center justify-center sm:items-stretch sm:justify-start">
                            <div className=" hidden sm:ml-6 sm:block">
                                <img className="h-8 w-auto" src="https://tailwindui.com/img/logos/mark.svg?color=indigo&shade=500" alt="Your Company"/>
                            </div>
                            <div className="hidden sm:ml-6 sm:block">
                                <div className="flex space-x-4">
                                    {/* <!-- Current: "bg-gray-900 text-white", Default: "text-gray-300 hover:bg-gray-700 hover:text-white" --> */}
                                    <NavLink to="/" className="rounded-md px-3 py-2 text-sm font-medium text-gray-300 hover:bg-gray-700 hover:text-white" aria-current="page">Home</NavLink>
                                    <NavLink to="/monitor" className="rounded-md px-3 py-2 text-sm font-medium text-gray-300 hover:bg-gray-700 hover:text-white">Monitor</NavLink>
                                    <a href="#" className="rounded-md px-3 py-2 text-sm font-medium text-gray-300 hover:bg-gray-700 hover:text-white">Projects</a>
                                    <a href="#" className="rounded-md px-3 py-2 text-sm font-medium text-gray-300 hover:bg-gray-700 hover:text-white">Calendar</a>
                                </div>
                            </div>
                        </div>

                        <div className=" flex flex-2 items-center justify-center">
                            <CustomerNav/>/
                            {/* for user */}
                            {/* <UserNav/> */}
                        </div>
                    </div>
                </div>

                {/* <!-- Mobile menu, show/hide based on menu state. --> */}
                <div className="sm:hidden" id="mobile-menu" ref={menuRef}>
                    {openBar&&(
                        <div className="space-y-1 px-2 pb-3 pt-2">
                            {/* <!-- Current: "bg-gray-900 text-white", Default: "text-gray-300 hover:bg-gray-700 hover:text-white" --> */}
                            <a href="#" className="block rounded-md px-3 py-2 text-base font-medium text-gray-300 hover:bg-gray-700 hover:text-white" aria-current="page">Dashboard</a>
                            <a href="#" className="block rounded-md px-3 py-2 text-base font-medium text-gray-300 hover:bg-gray-700 hover:text-white">Team</a>
                            <a href="#" className="block rounded-md px-3 py-2 text-base font-medium text-gray-300 hover:bg-gray-700 hover:text-white">Projects</a>
                            <a href="#" className="block rounded-md px-3 py-2 text-base font-medium text-gray-300 hover:bg-gray-700 hover:text-white">Calendar</a>
                        </div>
                    )}

                </div>
            </nav>
        </div>
    )
}

export default NavBar;