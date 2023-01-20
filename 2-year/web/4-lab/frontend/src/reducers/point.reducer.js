import {pointConstants} from "../constants";

export function points(state = [], action) {
    switch (action.type) {
        case pointConstants.CREATE_POINT:
            return [
                action.point,
                ...state
            ];
        case pointConstants.GET_POINTS:
            return [
                ...action.points
            ];
        case pointConstants.CLEAR_POINTS:
            return state.filter(({user}) => user.username !== action.username);
        default:
            return state;
    }
}