import {Button} from "reactstrap";
import {connect} from "react-redux";
import React from "react";
import {userActions} from "../actions";

const logout = () => {
    userActions.logout();
    window.location = "/#/signin";
}

const LogoutButton = () => (
    <Button className={"logout-button"} onClick={() => {logout()}}><span>Log out</span><i></i></Button>
)

export default connect()(LogoutButton)