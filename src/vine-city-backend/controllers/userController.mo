import Result "mo:base/Result";
import Error "mo:base/Error";
import Principal "mo:base/Principal";
import UserModel "../models/userModel";
import TrieMap "mo:base/TrieMap";
import Iter "mo:base/Iter";
import UtilityFunctions "../utils/utilityFunctions";
import UserTypes "../types/userTypes";
actor User{

    var userRecords=TrieMap.TrieMap<Principal,UserModel.User>(Principal.equal,Principal.hash);
    stable var stableUserRecords:[(Principal,UserModel.User)]=[];

    system func preupgrade(){
        stableUserRecords := Iter.toArray(userRecords.entries());
    };
    system func postupgrade(){
        let userRecordVals = stableUserRecords.vals();
        userRecords := TrieMap.fromEntries<Principal,UserModel.User>(userRecordVals,Principal.equal,Principal.hash);
        stableUserRecords := []; 
    };
    // to do -->

    // 1. createNewUser
    // 2. get user details
    // 3. update user 
    // 4. promote user
    // 5. banish user
    public shared ({caller}) func registerNewVinish(_userData:UserTypes.UserInputData):async Result.Result<Text,Text>{
        try{
            await UtilityFunctions.checkAnonymous(caller);
            switch(userRecords.get(caller)) {
                case(null) { 
                    let newUser:UserModel.User={
                        id=caller;
                        name=_userData.name;
                        email=_userData.email;
                        userType=#vinish;
                        govID="random";
                        karma=0;
                        vineCoins=0;
                        omruAccount=Principal.toText(caller);
                        communityID="";
                    };
                    userRecords.put(caller,newUser);
                    return #ok("Citizen registered with name : " # newUser.name);
                 };
                case(?user) { 
                    return #err("User already exists for this principal with name : " # user.name);
                };
            };
            return #err("Not complete yet");
        }catch e {
            return #err(Error.message(e));
        };
    };
    public shared ({caller}) func getUserDetails():async Result.Result<UserModel.User,Text>{
        try{
          await UtilityFunctions.checkAnonymous(caller);
          switch(userRecords.get(caller)) {
            case(null) { 
                return #err("No user found with this Principal!");
             };
            case(?user) { 
                return #ok(user);
            };
          };  
        }catch e{
            return #err(Error.message(e));
        };
    };
    // This function is public only for testing purposes, it will be private as only User actor will be able to use it
    // public shared func promoteUser(_user:Principal):async Result.Result<Text,Text>{
    //     switch(userRecords.get(_user)){
    //         case(?user){
                
    //         }
    //     }
    // }
};