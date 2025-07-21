import { useState, useEffect } from "react";

const GlobalNumbers = () => {
  const [submissions, setSubmissions] = useState([]);

  const fetchGlobal = async () => {
    try {
      const res = await fetch(`${process.env.REACT_APP_BASES_URL}/global_numbers`);
      const data = await res.json();
      setSubmissions(data.global_submissions || []);
    } catch (error) {
      console.error("Error fetching global numbers:", error);
    }
  };

  useEffect(() => {
    fetchGlobal();
  }, []);

  // Group armstrong numbers by user's email
  const groupedData = submissions.reduce((acc, item) => {
    if (item.armstrong) {
      if (!acc[item.user_email]) {
        acc[item.user_email] = [];
      }
      acc[item.user_email].push(item.number);
    }
    return acc;
  }, {});

  return (
    <div className="max-w-4xl mx-auto mt-10">
      <h2 className="text-2xl font-bold text-center mb-6">All Armstrong Numbers</h2>

      {Object.keys(groupedData).length === 0 ? (
        <p className="text-center text-gray-500">No Armstrong numbers found.</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full bg-white border border-gray-200 shadow-md rounded">
            <thead>
              <tr className="bg-gray-100 text-left">
                <th className="p-3 border-b">User Email</th>
                <th className="p-3 border-b">Armstrong Numbers</th>
              </tr>
            </thead>
            <tbody>
              {Object.entries(groupedData).map(([email, numbers], idx) => (
                <tr key={idx} className="border-t">
                  <td className="p-3 border-r">{email}</td>
                  <td className="p-3">{numbers.join(", ")}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default GlobalNumbers;
