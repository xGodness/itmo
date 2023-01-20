import {combineReducers} from "redux";
import {coords} from "./coords.reducer";
import {error} from "./error.reducer";
import {points} from "./point.reducer";

const rootReducer = combineReducers({
    coords,
    error,
    points: points
});

export default rootReducer;