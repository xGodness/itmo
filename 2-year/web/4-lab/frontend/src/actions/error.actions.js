import {errorConstants} from "../constants";

export const errorActions = {
    success,
    error,
    clear
};

function success(message) {
    return {type: errorConstants.SUCCESS, message};
}

function error(message) {
    return {type: errorConstants.ERROR, message};
}

function clear() {
    return {type: errorConstants.CLEAR};
}