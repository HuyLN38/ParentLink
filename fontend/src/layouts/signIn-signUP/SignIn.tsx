import React, { useState } from "react";
import { NavLink } from "react-router-dom";
function SignIn(){
    const [showPassword, setshowPassword] = useState(false);
    const showHandle =() =>{
        setshowPassword(!showPassword)
    }
    return(
<div className="min-h-screen bg-gray-100 py-6 flex flex-col justify-center sm:py-12">
	<div className="relative py-3 sm:max-w-xl sm:mx-auto">
		<div
			className="absolute inset-0 bg-gradient-to-r from-blue-300 to-blue-600 shadow-lg transform -skew-y-6 sm:skew-y-0 sm:-rotate-6 sm:rounded-3xl">
		</div>
		<div className="relative px-4 py-10 bg-white shadow-lg sm:rounded-3xl sm:p-20">
			<div className="max-w-md mx-5">
				<div className="flex flex-col items-center">
					<h1 className="text-2xl font-semibold">Login Form</h1>
				</div>
				<div className="divide-y divide-gray-200">
					<div className="py-8 text-base leading-6 space-y-4 text-gray-700 sm:text-lg sm:leading-7">
						{/* email */}
						<div className="relative">
							<input  id="email" name="email" type="text" className="text-sm pr-12 peer placeholder-transparent h-10 w-full border-b-2 border-gray-300 text-gray-900 focus:outline-none focus:borer-rose-600" placeholder="Email address" />
							<label className="absolute left-0 -top-3.5 text-gray-600 text-sm peer-placeholder-shown:text-base peer-placeholder-shown:text-gray-440 peer-placeholder-shown:top-2 transition-all peer-focus:-top-3.5 peer-focus:text-gray-600 peer-focus:text-sm">Email Address</label>
						</div>
						{/* password */}
						<div className="relative">
							<input id="password" name="password" type={showPassword?"text":"password"} className="text-sm pr-12 peer placeholder-transparent h-10 w-full border-b-2 border-gray-300 text-gray-900 focus:outline-none focus:borer-rose-600" placeholder="Password" />
							<label className="absolute left-0 -top-3.5 text-gray-600 text-sm peer-placeholder-shown:text-base peer-placeholder-shown:text-gray-440 peer-placeholder-shown:top-2 transition-all peer-focus:-top-3.5 peer-focus:text-gray-600 peer-focus:text-sm">Password</label>
                            {/* Eye show password */}
                            <div className="absolute inset-y-5 end-0 grid place-content-center px-4" onClick={()=>{setshowPassword(!showPassword)}}>
                                <i className={showPassword?"fa-regular fa-eye":"fa-regular fa-eye-slash"}></i>
                            </div>
						</div>
						<div className="relative flex justify-end text-base ">
							<button className="bg-blue-500 text-white hover:bg-cyan-950 transition ease-in duration-300 rounded-md px-4 py-1">Submit</button>

						</div>
                        <div className="relative flex text-end items-center">
                            <div className="text-sm">Continue with:</div>
                            <div className="space-x-2 justify-end flex-1">
                            <a href="#" className="fa-solid fa-envelope  text-[#c71610] text-2xl"></a>
                            <a href="#" className="fa-brands fa-facebook text-blue-500 text-2xl"></a>
                        </div>
                        </div>

                        <div className="relative flex justify-end">
                            <div className="text-sm me-2">No Account?</div>
                            <NavLink to="/sign-up" className="text-sm span-line"><span>Sign up</span></NavLink>
                        </div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
    )
}
export default SignIn;