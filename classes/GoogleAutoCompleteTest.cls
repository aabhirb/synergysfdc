/**
*@Description : XXXXXXXX
*@Author      : Vamsi Krishna Katragadda
*@Date        : 7/2/18.
*@JIRA        :
* Created by vkatragadda on 7/2/18.
Copyright (c) 7/2/18 Tesla All Rights Reserved.
**/
@IsTest
private class GoogleAutoCompleteTest
{
    static testMethod void testBehavior()
    {
        String Addr ='52 skytop st';
        String typ ='52 skytop st';
        String lng ='52 skytop st';
        GoogleAutoComplete.getAddressAutoComplete(Addr,typ,lng);
        GoogleAutoComplete.getAddressDetails('123456');
        GoogleAutoComplete.getAddressDetailsFromLatLong('123456','123456'); 
        GoogleAutoComplete.processWebResp('{json}');
        GoogleAutoComplete.processWebRes('sytsdsds');
        GoogleAutoComplete.parse('sytsdsds');
        GoogleAutoComplete.bumpCOverage();
    }
}