@isTest
private with sharing class GetAssetLiabilityRecords_Test {

    @testSetup static void setup() { 
        List<Asset_Liability__c> alRecordList = new List<Asset_Liability__c>();

        // Create 100 Assets
        for(Integer i = 0; i < 100; i++) {
            alRecordList.add(new Asset_Liability__c (
                            Name        = 'Test Name: '+ i,
                            Balance__c  = i,
                            Type__c     = 'Asset'
                            ));
        }

        // Create 100 Liabilities
        for(Integer i = 100; i < 200; i++) {
            alRecordList.add(new Asset_Liability__c (
                            Name        = 'Test Name: '+ i,
                            Balance__c  = i,
                            Type__c     = 'Liability'
                            ));
        }

        insert alRecordList;        
    }

    static testMethod void getAssetLiabilityListTest() {

        List<Asset_Liability__c> alQueryList = GetAssetLiabilityRecords.getAssetLiabilityList();

        
        System.assertNotEquals(alQueryList.size(), 0,'List should not be empty');
        System.assertEquals(alQueryList.size(), 200, 'List should be 200');

        for(Asset_Liability__c alRec : alQueryList) {
            System.assertNotEquals(alRec.Id, null, 'Record was created');
            System.assertNotEquals(alRec.Name, null, 'Name is not blank');
            System.assertNotEquals(alRec.Balance__c, null, 'Balance is not null');
            System.assertNotEquals(alRec.Type__c, null, 'Type is not null');
        }
    }

    static testMethod void deleteAssetLiabilityRecordsTest() {
        List<Id> recordsToDeleteList = new List<Id>();
       
        //List<Id> recordIds
        for(Asset_Liability__c record : [SELECT Id
                                        FROM Asset_Liability__c
                                        WITH SECURITY_ENFORCED]) {

            recordsToDeleteList.add(record.Id);
        }

        GetAssetLiabilityRecords.deleteAssetLiabilityRecords(recordsToDeleteList);

        List<Asset_Liability__c> deletedRecordsList = [SELECT Id, Name, Type__c, Balance__c
                                                      FROM Asset_Liability__c
                                                      WITH SECURITY_ENFORCED];
        
        System.assertEquals(deletedRecordsList.size(), 0, 'All records were deleted'); 
        System.assertEquals(deletedRecordsList.size(), 200, 'No records were deleted'); 
        
        for(Asset_Liability__c deletedRecord : deletedRecordsList) {
            System.assertEquals(deletedRecord.Id, null, 'Record is deleted');
            System.assertNotEquals(deletedRecord.Id, null, 'Record should not exist');

        }
    }

    static testMethod void calculateAssetsLiabilitiesTest() {
        Map<String, Decimal> calcRecordsMap =  GetAssetLiabilityRecords.calculateAssetsLiabilities();
        
        System.assertEquals(3, calcRecordsMap.values().size(), 'There is 3 map values: netWorth, assetsTotal, and liabilitiesTotal');
        System.assert(calcRecordsMap.containsKey('netWorth'), 'Map has a netWorth key');
        System.assert(calcRecordsMap.containsKey(''), 'Map should have a key that is not blank');
        System.assertNotEquals(calcRecordsMap.values(), null, 'There should be no null values');
    }
}
