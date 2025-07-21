import React, { useState, useEffect } from "react";
import axios from "axios";

const MyNumbers = () => {
  const [email, setEmail] = useState("");
  const [outputs, setOutputs] = useState([]);

  useEffect(() => {
    const storedEmail = localStorage.getItem("loggedInEmail");
    if (storedEmail) {
      setEmail(storedEmail);
      fetchMyNumbers(storedEmail);
    }
  }, []);

  const fetchMyNumbers = async (email) => {
    try {
      const res = await axios.post("http://localhost:4567/my_numbers", { email });
      if (res.data.outputs) {
        setOutputs(res.data.outputs);
      } else {
        alert(res.data.error || "No outputs found");
      }
    } catch (err) {
      console.error(err);
      alert(err.response?.data?.error || "Failed to fetch your numbers");
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 py-10 px-4 flex justify-center">
      <div className="w-full max-w-3xl bg-white p-8 rounded-2xl shadow-xl">
        <h2 className="text-3xl font-semibold text-center text-blue-700 mb-6">
          My Submitted Armstrong Numbers
        </h2>

        {outputs.length === 0 ? (
          <p className="text-center text-gray-500">No submissions found.</p>
        ) : (
          <ul className="space-y-4">
            {outputs.map((o, i) => (
              <li
                key={i}
                className="bg-gray-100 border border-gray-200 rounded-lg p-5 shadow-sm hover:shadow-md transition"
              >
                <div className="flex items-center justify-between">
                  <span className="text-lg font-medium text-gray-800">
                    Number: {o.number}
                  </span>
                  <span
                    className={`text-sm font-semibold px-3 py-1 rounded-full ${
                      o.armstrong
                        ? "bg-green-100 text-green-700"
                        : "bg-red-100 text-red-700"
                    }`}
                  >
                    {o.armstrong ? "Armstrong" : "Not Armstrong"}
                  </span>
                </div>
                <p className="text-sm text-gray-500 mt-2">
                  Submitted: {new Date(o.submitted_at).toLocaleString()}
                </p>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
};

export default MyNumbers;
