import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";

const SubmitForm = () => {
  const [number, setNumber] = useState("");
  const [email, setEmail] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const storedEmail = localStorage.getItem("loggedInEmail");
    if (!storedEmail) {
      alert("Please login first!");
      navigate("/login");
    } else {
      setEmail(storedEmail);
    }
  }, [navigate]);

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      const res = await axios.post(`${process.env.REACT_APP_BASES_URL}/submit`, {
        email,
        number: parseInt(number),
      });

      alert(res.data.message);
    } catch (err) {
      console.error(err);
      alert(err.response?.data?.error || "Something went wrong");
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-100 to-green-100 flex items-center justify-center px-4">
      <div className="w-full max-w-md bg-white/80 backdrop-blur-md border border-white rounded-2xl shadow-2xl p-8">
        <h2 className="text-3xl font-bold text-center text-blue-700 mb-4">
          Submit Armstrong Number
        </h2>

        <div className="text-sm text-center text-gray-700 mb-6">
          Logged in as:{" "}
          <span className="font-semibold text-green-700">{email}</span>
        </div>

        <form onSubmit={handleSubmit} className="space-y-5">
          <div>
            <label
              htmlFor="number"
              className="block text-sm font-medium text-gray-800 mb-1"
            >
              Armstrong Number
            </label>
            <input
              type="number"
              id="number"
              placeholder="e.g. 153"
              value={number}
              onChange={(e) => setNumber(e.target.value)}
              required
              className="w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-400 transition"
            />
          </div>

          <button
            type="submit"
            className="w-full bg-gradient-to-r from-blue-600 to-green-500 hover:from-blue-700 hover:to-green-600 text-white py-2.5 rounded-lg font-semibold transition duration-300 shadow-md hover:shadow-lg"
          >
            Submit
          </button>
        </form>
      </div>
    </div>
  );
};

export default SubmitForm;
