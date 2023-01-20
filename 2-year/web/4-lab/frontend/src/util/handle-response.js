export function handleResponse(response) {
    if (!response.ok) {
        if (response.status === 401) {
            window.location = "/login";
        }
    }
}