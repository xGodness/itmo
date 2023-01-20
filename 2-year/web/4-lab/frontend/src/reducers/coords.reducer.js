import {coordsConstants} from "../constants";

export function coords(state = {x: 0, y: 0, r: 2}, action) {
    switch (action.type) {
        case coordsConstants.UPDATE_COORDS:
            return action.coords;
        default:
            return state;
    }
}