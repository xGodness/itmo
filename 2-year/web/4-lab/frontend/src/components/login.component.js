import {useEffect, useState} from "react";
import {InputText} from "primereact/inputtext";
import {Link} from "react-router-dom";
import {connect} from "react-redux";
import {userActions} from "../actions";


const LoginComponent = (props) => {
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");

    const login = (e) => {
        e.preventDefault();
        props.dispatch(userActions.login(
        {
                username: username,
                password: password
            }
        ));
    }

    return (
        localStorage.getItem("user") ? window.location = "/" :
            <div className={"login-div"}>
                <div className="header">
                    AAARRRGHH
                </div>
                <form onSubmit={login} className={"form"}>
                    <InputText maxLength={50} name={"username"} className={"username-input"}
                               value={username} placeholder={"Username"}
                               onChange={(e) => setUsername(e.target.value)}/><br/>
                    <InputText maxLength={50} name={"password"} className={"password-input"}
                               value={password} type={"password"} placeholder={"Password"}
                               onChange={(e) => setPassword(e.target.value)}/><br/>

                    <button className={"submit"} type={"submit"}><span>Submit</span><i></i></button><br/>
                    <Link className={"link"} to={"/signup"}>Register</Link>
                </form>
            </div>
    );
}

const mapStateToProps = (state) => {
    const {error} = state.error;
    return {
        error
    };
}

export default connect(mapStateToProps)(LoginComponent);