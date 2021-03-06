Attribute VB_Name = "AddContactMacro"
'$Id$
'
'Add Contact Macro 1.0
'
'Add Contact Macro is part of the macros4outlook project
'see https://sourceforge.net/apps/mediawiki/macros4outlook/index.php?title=Add_Contact_Macro or
'    http://sourceforge.net/projects/macros4outlook/ for more information
'
'For more information on Outlook see http://www.microsoft.com/outlook
'Outlook is (C) by Microsoft

'****************************************************************************
'License:
'
' sample Outlook 2003 VBA application by Sue Mosher
' send questions/comments to webmaster@outlookcode.com
' modified by daniel309@users.sourceforge.net
'****************************************************************************

'Changelog
'
'Version 1.0 - 2011-04-22
' * first public relese

Option Explicit


Private Const AUTO_CONTACT_FOLDER_NAME As String = "AutoContacts"




Public Sub AddRecipToContacts(ByVal MailItem As Object)
    Dim strFind As String
    
    Dim objNS As Outlook.NameSpace
    Dim colContacts As Outlook.Items
    Dim objContact As Outlook.ContactItem
    Dim objRecip As Outlook.Recipient
    Dim objContactFolder As MAPIFolder
    Dim objNewContactFolder As MAPIFolder
    Dim objMailItem As MailItem
    
    Dim i As Integer
    

    'CAST
    Set objMailItem = MailItem
    

    ' get Contacts folder and its Items collection
    Set objNS = Application.GetNamespace("MAPI")
    Set objContactFolder = objNS.GetDefaultFolder(olFolderContacts)
    
    On Error Resume Next  'to skip error if folder isn't in .Folders(...)!
    'see if autocontactfolder already exists
    Set objNewContactFolder = objContactFolder.Folders(AUTO_CONTACT_FOLDER_NAME)
    If (objNewContactFolder Is Nothing) Then 'error occured!
        Set objNewContactFolder = objContactFolder.Folders.Add(AUTO_CONTACT_FOLDER_NAME)
    End If
    On Error GoTo 0
    
    
    Set colContacts = objNewContactFolder.Items
    
    ' process message recipients
    For Each objRecip In objMailItem.Recipients
        ' check to see if the recip is already in Contacts
        For i = 1 To 3
            strFind = "[Email" & i & "Address] = " & AddQuote(objRecip.Address)
            Set objContact = colContacts.Find(strFind)
            If Not objContact Is Nothing Then
                'MsgBox objRecip.Address & " already in addressbook!"
                Exit For
            End If
        Next

        ' if not, add it
        If objContact Is Nothing Then
            Set objContact = Application.CreateItem(olContactItem)
            With objContact
                .FullName = Replace(objRecip.Name, "'", "")
                .Email1Address = objRecip.Address
                .Save
                .Move objNewContactFolder
            End With
            'MsgBox "added " & objRecip.name & " to addressbook!"
        End If
        Set objContact = Nothing
    Next

    Set objNS = Nothing
    Set objContact = Nothing
    Set colContacts = Nothing
    Set objContactFolder = Nothing
    Set objNewContactFolder = Nothing
End Sub

Private Function AddQuote(MyText As String) As String
    AddQuote = Chr(34) & MyText & Chr(34)
End Function
