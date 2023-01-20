import React from "react";
import "primereact/resources/themes/bootstrap4-dark-blue/theme.css";
import "primereact/resources/primereact.min.css";
import "primeicons/primeicons.css";
import Login from "./components/login.component";
import {HashRouter, Route, Routes} from "react-router-dom";
import Register from "./components/register.component";
import {connect} from "react-redux";
import "./css/styles.css";
import Main from "./Main";
import "./css/App.css";

const App = (props) => {
    const {error} = props;
    return (
        <div>
            <HashRouter>
                <Routes>
                    <Route exact path={"/signin"} element={<Login/>}/>
                    <Route exact path={"/signup"} element={<Register/>}/>
                    <Route exact path={"/"} element={<Main/>}/>
                </Routes>
            </HashRouter>
            {
                error &&
                error.message &&
                <div className={"errors"}>
                    {error.message.map(
                        error => {
                            return (
                                <span key={error}>
                                        {error}<br/>
                                    </span>
                            );
                        }
                    )}
                </div>
            }
        </div>
    );
}

const mapStateToProps = (state) => {
    const {error} = state;
    return {
        error
    };
}

export default connect(mapStateToProps)(App)