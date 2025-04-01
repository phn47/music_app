

export async function fetchSongs() {
    try {
        // Lấy token từ LocalStorage hoặc từ bất kỳ nơi nào bạn lưu trữ token
        // const token = localStorage.getItem("x-auth-token"); // hoặc bạn có thể thay đổi cách lấy token nếu cần

        const response = await fetch(`http://127.0.0.1:8000/song/listwed`, {
            method: 'POST', // hoặc 'POST' tùy vào endpoint
            headers: {
                // 'x-auth-token': `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEzNGI4YzRmLTM3ZmQtNDYxMi1iY2M0LTU3YWE2Zjg5MGRlMiJ9.2QRM7qEiWQvm2R7beHy0V9FQklTOwDZjc39v6HL9bIA`, // Thêm header Authorization
                'Content-Type': 'application/json' // Đảm bảo là header kiểu JSON
            }
        });

        if (!response.ok) {
            throw new Error("Failed to fetch songs");
        }

        return await response.json(); // Trả về dữ liệu JSON từ server
    } catch (error) {
        console.error("Error fetching songs:", error);
        throw error;
    }
}


