trigger SuperDeduplication on Lead (before insert) {
    
    List<Group> dataQualityGroups = [SELECT Id
                                     FROM Group 
                                     WHERE DeveloperName = 'Data Quality'
                                     LIMIT 1];

    for (Lead myLead : Trigger.new) {
        if (myLead.Email != null) {
        // search for matching contacts 
        // Store the results of our SOQL query in a list of contacts
        List<Contact> matchingContacts = [SELECT Id, 
                                                 FirstName, 
                                                 LastName, 
                                                 Account.Name
                                            FROM Contact
                                            WHERE Email = :myLead.Email];

        System.debug(matchingContacts.size() + 'thats how many matches');
        // if matches are found...
        if (!matchingContacts.isEmpty()) {

        // assign the lead to the data quality queue
            if (!dataQualityGroups.isEmpty()) {
            myLead.OwnerID = dataQualityGroups.get(0).Id;
            }
        

        // add the dupe contact IDs into the lead description 
            String dupeContactMessage = 'Duplicate contact(s) found:\n';
            for (Contact matchingContact : matchingContacts) {
                dupeContactMessage += matchingContact.FirstName + ' ' 
                                    + matchingContact.LastName + ', '
                                    + matchingContact.Account.Name + ' ('
                                    + matchingContact.Id + ')\n';
            }
            if (myLead.Description != null) {
                myLead.Description = dupeContactMessage + '\n' + myLead.Description;
            }
        }
    }
    }
}