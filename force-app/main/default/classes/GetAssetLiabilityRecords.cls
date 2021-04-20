/*
*	Author: Dionne Petty
*	Description: This code is used for Coding Challenge LWC Components 
*	Created:- 04/17/2021
*	Last Updated:- 04/20/2020
*/

public with sharing class GetAssetLiabilityRecords {
    @AuraEnabled(cacheable=true)
    public static List<Asset_Liability__c> getAssetLiabilityList() {
        try {
            return [SELECT Id, Name, Type__c, Balance__c
                    FROM Asset_Liability__c
                    WITH SECURITY_ENFORCED
                    ];
        } catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return new List<Asset_Liability__c>();
        }
    }

    @AuraEnabled
    public static void deleteAssetLiabilityRecords(List<Id> recordIds) {
        try {
            List<Asset_Liability__c> recordsToDelete = new List<Asset_Liability__c>();

            for(Id recordId : recordIds) {
                recordsToDelete.add(new Asset_Liability__c(Id = recordId));
            }

            if(!recordsToDelete.isEmpty()) {
                delete recordsToDelete;
            }
        } catch(DMLException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Decimal> calculateAssetsLiabilities() {
        Map<String, Decimal> alcMap = new Map<String, Decimal>();
        Decimal netWorth = 0;

       try {
        //Assets Total
        for(AggregateResult aSum : [SELECT Sum(Balance__c) FROM Asset_Liability__c
                                    WHERE Type__c = 'Asset'
                                    WITH SECURITY_ENFORCED
       ]) {

            if(aSum.get('expr0') == null) {
                alcMap.put((String)'assetsTotal', 0);
            } else {
                alcMap.put((String)'assetsTotal', (Decimal)aSum.get('expr0'));
            }
        }

        //Liabilities Total
        for(AggregateResult lSum : [SELECT Sum(Balance__c) FROM Asset_Liability__c
                                    WHERE Type__c = 'Liability'
                                    WITH SECURITY_ENFORCED
        ]) {
            
            if(lSum.get('expr0') == null ) {
                alcMap.put((String)'liabilitiesTotal', 0);
            } else {
                alcMap.put((String)'liabilitiesTotal', (Decimal)lSum.get('expr0'));
            }
        }

        //Net worth get values from map and then add sum to map
        netWorth = alcMap.get('assetsTotal') + alcMap.get('liabilitiesTotal');

        alcMap.put((String)'netWorth', (Decimal)netWorth);

        return alcMap;

       } catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return alcMap;
       }
    
    }

}
