import Principal "mo:base/Principal";
import Error "mo:base/Error";
module {
    public func checkAnonymous(_caller:Principal):async(){
        if(Principal.isAnonymous(_caller)){
            let err=Error.reject("Anonymous users are forbidden for this action !");
            throw err;
        };
    };
}