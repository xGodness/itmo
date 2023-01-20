import {pointService} from "../services";
import {pointConstants} from "../constants";
import {userActions} from "./user.actions";

export const pointAction = {
    createPoint,
    clearPoints,
    getPoints
}

function createPoint(point) {
    return dispatch => {
        pointService.createPoint(point)
            .then(response => {
                dispatch({type: pointConstants.CREATE_POINT, point: response.data});
            })
            .catch(error => {
                if (error.response && error.response.status === 401) {
                    userActions.logout();
                    window.location = "/#/signin";
                }
            });
    }
}

function clearPoints() {
    return dispatch => {
        pointService.clearPoints()
            .then(() => {
                dispatch({type: pointConstants.CLEAR_POINTS, username: localStorage.getItem("username")});
            })
            .catch(error => {
                if (error.response && error.response.status === 401) {
                    userActions.logout();
                    window.location = "/#/signin";
                }
            });
    }
}

function getPoints() {
    return dispatch => {
        pointService.getPoints()
            .then(response => {
                dispatch({type: pointConstants.GET_POINTS, points: response.data});
            })
            .catch(error => {
                if (error.response && error.response.status === 401) {
                    userActions.logout();
                    window.location = "/#/signin";
                }
            });
    }
}