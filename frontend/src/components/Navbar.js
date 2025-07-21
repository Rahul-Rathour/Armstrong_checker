import React, { useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import {
  FaSignOutAlt,
  FaSignInAlt,
  FaUserPlus,
  FaHome,
} from "react-icons/fa";

const Navbar = () => {
  const [loggedIn, setLoggedIn] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    const storedEmail = localStorage.getItem("loggedInEmail");
    setLoggedIn(!!storedEmail);
  }, [localStorage.getItem("loggedInEmail")]);

  const handleLogout = () => {
    localStorage.removeItem("loggedInEmail");
    setLoggedIn(false);
    navigate("/login");
  };

  return (
    <nav className="bg-white shadow-sm border-b border-gray-200 py-3 px-6">
      <div className="max-w-7xl mx-auto flex justify-between items-center">
        {/* Logo */}
        <Link
          to="/"
          className="text-xl font-semibold text-blue-600 flex items-center gap-2 hover:scale-105 transition-transform"
        >
          <FaHome className="text-lg" />
          Armstrong App
        </Link>

        {/* Navigation Links */}
        <div className="flex items-center gap-5 text-gray-700 text-sm font-medium">
          <Link
            to="/"
            className="hover:text-blue-600 transition-colors flex items-center gap-1"
          >
            <FaUserPlus className="text-base" />
            Register
          </Link>

          {!loggedIn && (
            <Link
              to="/login"
              className="hover:text-blue-600 transition-colors flex items-center gap-1"
            >
              <FaSignInAlt className="text-base" />
              Login
            </Link>
          )}

          {loggedIn && (
            <>
              <Link
                to="/submit"
                className="hover:text-blue-600 transition-colors"
              >
                Submit
              </Link>
              <Link
                to="/my-numbers"
                className="hover:text-blue-600 transition-colors"
              >
                My Numbers
              </Link>
            </>
          )}

          <Link
            to="/global"
            className="hover:text-blue-600 transition-colors"
          >
            Global
          </Link>

          {loggedIn && (
            <button
              onClick={handleLogout}
              className="flex items-center gap-1 bg-red-500 text-white px-3 py-1.5 rounded-md hover:bg-red-600 transition"
            >
              <FaSignOutAlt className="text-sm" />
              Logout
            </button>
          )}
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
