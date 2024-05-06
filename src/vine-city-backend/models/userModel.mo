import Text "mo:base/Text";
import Principal "mo:base/Principal";
import UserTypes "../types/userTypes";
module{
    public type User={
        id:Principal;
        name:Text;
        email:Text;
        govID:Text;
        userType:UserTypes.userTypes;
        karma:Nat;
        vineCoins:Nat;
        omruAccount:Text;
        communityID:Text;
    }
}