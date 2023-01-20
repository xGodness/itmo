import {authHeader} from "../util/auth-header";
import axios from "axios";

export const pointService = {
    getPoints,
    clearPoints,
    createPoint
}

function getPoints() {
    const requestOptions = {
        method: "GET",
        headers: {
            ...authHeader()
        }
    };
    return axios("/points", requestOptions);
}

function clearPoints() {
    const requestOptions = {
        method: "DELETE",
        headers: {
            ...authHeader()
        }
    };
    return axios("/points", requestOptions);
}

function createPoint(point) {
    const requestOptions = {
        method: "POST",
        headers: {
            ...authHeader(),
            "Content-Type": "application/json"
        },
        data: point
    };
    return axios("/points", requestOptions);
}