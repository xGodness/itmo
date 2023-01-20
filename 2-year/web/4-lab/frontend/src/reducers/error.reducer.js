import {errorConstants} from "../constants";

export function error(state = {}, action) {
    switch (action.type) {
        case errorConstants.ERROR:
            return {
                type: "has-error",
                message: action.message
            };
        case errorConstants.SUCCESS:
            return {
                type: "no-error",
                message: action.message
            };
        case errorConstants.CLEAR:
            return {};
        default:
            return state;
    }
}