export function authHeader() {
    const user = localStorage.getItem("user");
    if (user) {
        return {"Authorization": "Basic " + user};
    } else {
        return {};
    }
}