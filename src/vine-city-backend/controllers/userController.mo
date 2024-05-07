import Result "mo:base/Result";
import Error "mo:base/Error";
import Principal "mo:base/Principal";
import UserModel "../models/userModel";
import TrieMap "mo:base/TrieMap";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import UtilityFunctions "../utils/utilityFunctions";
import UserTypes "../types/userTypes";
import Constants "../utils/constants";
actor User{

    var userRecords=TrieMap.TrieMap<Principal,UserModel.User>(Principal.equal,Principal.hash);
    stable var stableUserRecords:[(Principal,UserModel.User)]=[];
    var secureCanisters:Buffer.Buffer<Text> = Buffer.empty<Text>();

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

    // New user regustration as vinish in Vine City 
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

    // Get user  details
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

    // Apply for vinish to resident promotion
    public shared ({caller}) func applyPromotionToResident():async Result.Result<Text,Text>{
        try{
            await UtilityFunctions.checkAnonymous();
            switch(userRecords.get(caller)){
                case(?user){
                    if(user.vineCoins < Constants.VINE_COINS_FOR_RESIDENT_PROMOTION){
                        return #err("Not enough vine coins for vinish to resident promotion!");
                    };
                    if(user.userType != #vinish){
                        return #err("You are already a resident !");
                    };
                    let updatedUser:UserModel.User={
                        id=caller;
                        name=user.name;
                        email=user.email;
                        userType=#resident;
                        govID=user.govID;
                        karma=user.karma;
                        vineCoins=user.vineCoins;
                        omruAccount=user.omruAccount;
                        communityID=user.communityID;
                    };
                    ignore userRecords.replace(caller,updatedUser);
                    return #ok("User successfully promoted to resident");
                };
                case(null){
                    return #err("No user found for this Principal!");
                };
            };
        }catch e{
            return #err(Error.message(e));
        }
    };

    // Update user
    public shared ({caller}) func updateUser(_userInfo:UserTypes.UserInputData):async Result.Result<UserModel.User,Text>{
        try{
            await UtilityFunctions.checkAnonymous();
            switch(userRecords.get(caller)){
            case(null){
                return #err("No user found for this Principal!");
            };
            case(?user){
                let updatedUser:UserModel.User={
                    id=caller;
                    name=_userInfo.name;
                    email=_userInfo.email;
                    userType=user.userType;
                    govID=user.govID;
                    karma=user.karma;
                    vineCoins=user.vineCoins;
                    omruAccount=user.omruAccount;
                    communityID=user.communityID;
                };
                ignore userRecords.replace(caller,updatedUser);
                return #ok(updatedUser);
            };
        };
        }catch e {
            return #err(Error.message(e));
        }
    };

    // Banish User - Can only be called by the user and other canisters of the vine city
    private func banishUser(_userID:Principal):Result.Result<Text,Text>{
        switch(userRecords.get(caller)){
            case(null){
                return #err("No user found for this Principal!");
            };
            case(?user){
                userRecords.delete(_userID);
                return #ok("User banished successfully!");
            };
        };
    };
};