import React from "react";
import logo from "./logo.svg";
import NavBar from "./layouts/header-footer/Navbar";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import SignIn from "./layouts/signIn-signUP/SignIn";
import SignUp from "./layouts/signIn-signUP/SignUp";
import Footer from "./layouts/header-footer/Footer";
import Homepage from "./layouts/homepage/Homepage";
import Monitor from "./layouts/monitor/Monitor";

function App() {
  return (
    <div>
      <BrowserRouter>
        <NavBar />
        <Routes>
          <Route path="/sign-in" element={<SignIn />}></Route>
          <Route path="/sign-up" element={<SignUp />}></Route>
          <Route path="/" element={<Homepage />}></Route>
          <Route path="/monitor" element={<Monitor />}></Route>
        </Routes>
        <Footer />
      </BrowserRouter>
    </div>
  );
}

export default App;
