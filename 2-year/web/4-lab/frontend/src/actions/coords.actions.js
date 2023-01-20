import {coordsConstants} from "../constants";

export const coordsAction = {
    updateCoords
}

function updateCoords(coords) {
    return dispatch => {
        dispatch({type: coordsConstants.UPDATE_COORDS, coords})
    }
}