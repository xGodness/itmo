import {Provider} from "react-redux";
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import {store} from "./util";
import {useMediaQuery} from "react-responsive"

const Desktop = React.lazy(() => import("./css/desktop"));
const Tablet = React.lazy(() => import("./css/tablet"));
const Mobile = React.lazy(() => import("./css/mobile"));


const DeviceSelector = ({children}) => {
    const isDesktop = useMediaQuery({
        query: "(min-width: 1075px)",
    });
    const isTablet = useMediaQuery({
        query: "(min-width: 753px)"
    });
    return (
        <>
            <React.Suspense fallback={<></>}>
                <Desktop/>
                {isDesktop && <Desktop/>}
                {!isDesktop && isTablet && <Tablet/>}
                {!isDesktop && !isTablet && <Mobile/>}
            </React.Suspense>
            {children}
        </>
    );
}


const root = ReactDOM.createRoot(document.getElementById("root"));

root.render(
    <Provider store={store}>
        <App/>
    </Provider>
);


