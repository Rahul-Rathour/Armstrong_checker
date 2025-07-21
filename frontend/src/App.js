
import React from "react";
import RegisterForm from "./components/RegisterForm";
import LoginForm from "./components/LoginForm";
import SubmitForm from "./components/SubmitForm";
import MyNumbers from "./components/MyNumbers";
import GlobalNumbers from "./components/GlobalNumbers";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import Navbar from "./components/Navbar";

function App() {
  return (
    <>
      <BrowserRouter>
        <Navbar />
        <Routes>
          <Route path="/" element={<RegisterForm />} />
          <Route path="/login" element={<LoginForm />} />
          <Route path="/submit" element={<SubmitForm />} />
          <Route path="/my-numbers" element={<MyNumbers />} />
          <Route path="/global" element={<GlobalNumbers />} />
        </Routes>
      </BrowserRouter>
    </>
  );
}

export default App;
