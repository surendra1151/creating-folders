Add-Type -assembly System.Windows.Forms
Add-Type -assembly System.Drawing
#$instructorName = "timur.masiagut@smailastate.edu"

Function CreateClassFolder($folderPath)
{

if(-not(Test-Path -Path $folderPath)){

    New-Item -ItemType directory -Path $folderPath
    }
   
}

Function CreateFolders($folderPath, $studentFilePath)
{
     $students = Get-Content   $studentFilePath

    
    #Create folders for students
   
    foreach ($student in $students)
    {
    $path = $folderPath +'\'+ $student.ToString()
        if(-not(Test-Path -Path $path)){
        
        New-Item -ItemType directory -Path $path
        }
    }
     
     ClearFolderPermission ($ClassPathTextBox.Text+$ClassNameTextBox.Text) $StudentListTextBox.Text $InstructorListTextBox.Text
     AssignInstructorRights ($ClassPathTextBox.Text+$ClassNameTextBox.Text+'\') $InstructorListTextBox.Text
     AssignStudentRights ($ClassPathTextBox.Text+$ClassNameTextBox.Text+'\') $StudentListTextBox.Text 
     

}

Function AssignStudentRights($folderPath, $studentFilePath)
{
    $students = Get-Content $studentFilePath
    $studentFolders = dir $folderPath
    $AclFolderPath = $folderPath

    $folderAcl = Get-Acl $AclFolderPath
    foreach($student in $students)
    {
    if($student)
    {
    $studentName = $student.ToString()

        $AclPath = $folderPath + $studentName+'\'
        $studentAcl = Get-Acl $AclPath
        $StudentAr = New-Object system.security.accesscontrol.filesystemaccessrule($studentName,"Modify","ContainerInherit,ObjectInherit","None","Allow")
        $studentAcl.SetAccessRule($StudentAr)
        $StudentfolAr = New-Object system.security.accesscontrol.filesystemaccessrule($studentName,"Read","Allow")
        $folderAcl.SetAccessRule($StudentfolAr)
        
        $Ar = New-Object system.security.accesscontrol.filesystemaccessrule("Administrators","FullControl","ContainerInherit,ObjectInherit","None","Allow")
        $studentAcl.SetAccessRule($Ar)

        $CourseWorkPath = $folderPath +"Coursework\"
        $CourseWorkAcl = Get-Acl $CourseWorkPath
        $CourseWorkAr = New-Object system.security.accesscontrol.filesystemaccessrule($studentName,"ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow")
        $CourseWorkAcl.SetAccessRule($CourseWorkAr)


       (Get-Item $CourseWorkPath).SetAccessControl($CourseWorkAcl)
     
        (Get-Item $AclPath).SetAccessControl($studentAcl)
        
         (Get-Item $AclFolderPath).SetAccessControl($folderAcl)

       
}
   
    }
    
}

#Create folder for instructors
Function CreateInstructorFolder($folderPath, $instructorFilePath)
{
    #Create folder for instructor

    #Adding instuctor name to text file
    $instructors = Get-Content $instructorFilePath
    $path = $folderPath + "Coursework"
    if(-not(Test-Path -Path $path)){
    
    New-Item -ItemType directory -Path $path
    }
    AssignInstructorRights ($ClassPathTextBox.Text+$ClassNameTextBox.Text+'\') $InstructorListTextBox.Text 

}

Function AssignInstructorRights($folderPath, $instructorFilePath)
{
Write-Output "File path"
  
    $instructors = Get-Content $instructorFilePath

    $allFolders = dir $folderPath

    $AclFolderPath = $folderPath

    $folderAcl = Get-Acl $AclFolderPath
     

    foreach ($folder in $allFolders)
    {
        $AclPath = $folderPath + $folder.ToString()
        $Acl = Get-Acl $AclPath

        
        foreach ($instructor in $instructors)
        {
            if($instructor){
            
$InstructorfolAr=New-Object system.security.accesscontrol.filesystemaccessrule($instructor.ToString(),"FullControl","ContainerInherit,ObjectInherit","None","Allow")
            
        $folderAcl.SetAccessRule($InstructorfolAr)
          (Get-Item $AclFolderPath).SetAccessControl($folderAcl)
        
        }

        $Ar = New-Object system.security.accesscontrol.filesystemaccessrule("Administrators","FullControl","ContainerInherit,ObjectInherit","None","Allow")
        $Acl.SetAccessRule($Ar)

        (Get-Item $AclPath).SetAccessControl($Acl)

       }
    }
   

    
    
}

Function ClearFolderPermission($folderPath, $studentFilePath, $instructorFilePath)
{
    
    #Adding student and instructor names to file path
    
    
    $students = Get-Content $studentFilePath
    $instructors = Get-Content $instructorFilePath
    $AclPath = $folderPath

    $studentAcl = Get-Acl $AclPath
    $studentAcl.SetAccessRuleProtection($true,$false)

   
    foreach ($instructor in $instructors)

    {
        if($instructor){
         $StudentAr = New-Object system.security.accesscontrol.filesystemaccessrule($instructor.ToString(),"FullControl","Allow")
        $studentAcl.SetAccessRule($StudentAr)
      
       }
       
    }

    foreach ($student in $students)
    {
     if($student){
      $StudentAr = New-Object system.security.accesscontrol.filesystemaccessrule($student.ToString(),"Read","Allow")
        $studentAcl.SetAccessRule($StudentAr)
        
        }
       
    }

    
    $Ar = New-Object system.security.accesscontrol.filesystemaccessrule("Administrators","FullControl","Allow")
    $studentAcl.SetAccessRule($Ar)

    (Get-Item $AclPath).SetAccessControl($studentAcl)
   
}

Function FullProcess($ClassPath,$ClassName, $studentFilePath,$instructorFilePath)
{

    CreateClassFolder ($ClassPathTextBox.Text+$ClassNameTextBox.Text)

    ClearFolderPermission ($ClassPathTextBox.Text+$ClassNameTextBox.Text) $StudentListTextBox.Text $InstructorListTextBox.Text 

    CreateInstructorFolder ($ClassPathTextBox.Text+$ClassNameTextBox.Text+'\') $InstructorListTextBox.Text 
    CreateFolders ($ClassPathTextBox.Text+$ClassNameTextBox.Text) $StudentListTextBox.Text  

    

    #AssignInstructorRights ($ClassPathTextBox.Text+$ClassNameTextBox.Text+'\') $InstructorListTextBox.Text    

    #AssignStudentRights ($ClassPathTextBox.Text+$ClassNameTextBox.Text+'\') $StudentListTextBox.Text  
}



#create interface
Function CreateInterface
{
    #initialize window
    $window_form = New-Object System.Windows.Forms.Form
    $window_form.Text ='Class Helper'
    $window_form.Width = 1000
    $window_form.Height = 600
    $window_form.AutoSize = $true

    #creation of Radio Button
    
   $RadioButton1 = New-Object System.Windows.Forms.RadioButton
    $RadioButton1.Location = '400,50' 
    $RadioButton1.size = '110,60'
    $RadioButton1.Checked = $true
    $RadioButton1.Text = "Full Process"
    $window_form.Controls.Add($RadioButton1)
 
    $RadioButton2 = New-Object System.Windows.Forms.RadioButton
    $RadioButton2.Location = '400,100'
    $RadioButton2.size = '150,60'
    $RadioButton2.Checked = $false
    $RadioButton2.Text = "Student Folder"
    $window_form.Controls.Add($RadioButton2)
 
    $RadioButton3 = New-Object System.Windows.Forms.RadioButton
    $RadioButton3.Location = '400,150'
    $RadioButton3.size = '150,60'
    $RadioButton3.Checked = $false
    $RadioButton3.Text = "Instructor"
    $window_form.Controls.Add($RadioButton3)

      #condition for displaying
    
      if($RadioButton1.Checked -eq $true ){
      #Class name
    $ClassNameLabel = New-Object System.Windows.Forms.Label
    $ClassNameLabel.Text = "Class Name"
    $ClassNameLabel.Location  = New-Object System.Drawing.Point(20,195)
    $ClassNameLabel.AutoSize = $true
    $window_form.Controls.Add($ClassNameLabel)

    $ClassNameTextBox = New-Object System.Windows.Forms.TextBox
    $ClassNameTextBox.AutoSize = $false;
    $ClassNameTextBox.Size = New-Object System.Drawing.Size(300,25)
    $ClassNameTextBox.Location  = New-Object System.Drawing.Point(20, 220)
    #$ClassPathTextBox.Text = 'C:\Rabota\ag-geo\classes\class1\'
     $ClassNameTextBox.Text = 'MyClass'
     $ClassNameTextBox.Font = New-Object System.Drawing.Font("Lucida Console",10,[System.Drawing.FontStyle]::Regular)
    $window_form.Controls.Add($ClassNameTextBox)

    #Class folder path
    $ClassPathLabel = New-Object System.Windows.Forms.Label
    $ClassPathLabel.Text = "Path to class folder:"
    $ClassPathLabel.Location  = New-Object System.Drawing.Point(20,10)
    $ClassPathLabel.AutoSize = $true
    $window_form.Controls.Add($ClassPathLabel)

    $ClassPathTextBox = New-Object System.Windows.Forms.TextBox
    $ClassPathTextBox.AutoSize = $false;
    $ClassPathTextBox.Size = New-Object System.Drawing.Size(300,25)
    $ClassPathTextBox.Location  = New-Object System.Drawing.Point(20, 35)
    #$ClassPathTextBox.Text = 'C:\Rabota\ag-geo\classes\class1\'
    $ClassPathTextBox.Text = '\\ag-geo\Classes\'
     $ClassPathTextBox.Font = New-Object System.Drawing.Font("Lucida Console",10,[System.Drawing.FontStyle]::Regular)
    $window_form.Controls.Add($ClassPathTextBox)

    #Student txt file path
    $StudentListLabel = New-Object System.Windows.Forms.Label
    $StudentListLabel.Text = "Student List:"
    $StudentListLabel.Location  = New-Object System.Drawing.Point(20,70)
    $StudentListLabel.AutoSize = $true
    $window_form.Controls.Add($StudentListLabel)

    $StudentListTextBox = New-Object System.Windows.Forms.TextBox
    $StudentListTextBox.AutoSize = $false;
    $StudentListTextBox.Size = New-Object System.Drawing.Size(300,25)
    $StudentListTextBox.Location  = New-Object System.Drawing.Point(20, 95)
    # $StudentListTextBox.Text = 'E:\Admin\list.txt'
    $StudentListTextBox.Text = '\\ag-geo\Admin\list.txt'
     $StudentListTextBox.Font = New-Object System.Drawing.Font("Lucida Console",10,[System.Drawing.FontStyle]::Regular)
    
    $window_form.Controls.Add($StudentListTextBox)

    #Instructors txt file path
    $InstructorListLabel = New-Object System.Windows.Forms.Label
    $InstructorListLabel.Text = "Instructor List:"
    $InstructorListLabel.Location  = New-Object System.Drawing.Point(20,125)
    $InstructorListLabel.AutoSize = $true
    $window_form.Controls.Add($InstructorListLabel)

    $InstructorListTextBox = New-Object System.Windows.Forms.TextBox
    $InstructorListTextBox.AutoSize = $false;
    $InstructorListTextBox.Size = New-Object System.Drawing.Size(300,25)
    $InstructorListTextBox.Location  = New-Object System.Drawing.Point(20, 150)
    $InstructorListTextBox.Text = '\\ag-geo\Admin\instructors.txt'

    $InstructorListTextBox.Font = New-Object System.Drawing.Font("Lucida Console",10,[System.Drawing.FontStyle]::Regular)
    $window_form.Controls.Add($InstructorListTextBox)
      }




      #condition to display radio button
      $RadioButton1.Add_Click({
       $ClassNameLabel.Location  = New-Object System.Drawing.Point(20,195)
        $ClassNameTextBox.Location  = New-Object System.Drawing.Point(20, 220)
       $window_form.Controls.Add($ClassNameTextBox)
       $window_form.Controls.Add($ClassNameLabel)
        $window_form.Controls.Add($ClassPathLabel)
        $window_form.Controls.Add($ClassPathTextBox)
        $window_form.Controls.Add($StudentListLabel)
        $window_form.Controls.Add($StudentListTextBox)
        $InstructorListLabel.Location  = New-Object System.Drawing.Point(20,125)
        $InstructorListTextBox.Location  = New-Object System.Drawing.Point(20, 150)

        $window_form.Controls.Add($InstructorListLabel)
        $window_form.Controls.Add($InstructorListTextBox)
        $window_form.Controls.Remove($StudentNameLabel)
        $window_form.Controls.Remove($StudentNameTextBox)
        $window_form.Controls.Remove($InstructorNameLabel)
        $window_form.Controls.Remove($InstructorNameTextBox)
      })

       $RadioButton2.Add_Click({
        $window_form.Controls.Remove($InstructorNameLabel)
        $window_form.Controls.Remove($InstructorNameTextBox)
        $ClassNameLabel.Location  = New-Object System.Drawing.Point(20,125)
        $ClassNameTextBox.Location  = New-Object System.Drawing.Point(20, 150)
        $window_form.Controls.Add($ClassNameTextBox)
        $window_form.Controls.Add($ClassNameLabel)
        $window_form.Controls.Add($ClassPathLabel)
        $window_form.Controls.Add($ClassPathTextBox)
        $window_form.Controls.Add($StudentListLabel)
        $window_form.Controls.Add($StudentListTextBox)
        $window_form.Controls.Remove($InstructorListLabel)
        $window_form.Controls.Remove($InstructorListTextBox)      
        

      })
   
 
        $RadioButton3.Add_Click({
         $window_form.Controls.Add($ClassNameTextBox)
         $window_form.Controls.Add($ClassNameLabel)
         $window_form.Controls.Add($ClassPathLabel)
         $window_form.Controls.Add($ClassPathTextBox)
         $window_form.Controls.Remove($StudentListLabel)
         $window_form.Controls.Remove($StudentListTextBox)
         $window_form.Controls.Add($InstructorListLabel)
         $window_form.Controls.Add($InstructorListTextBox)
         $window_form.Controls.Remove($StudentNameLabel)
         $window_form.Controls.Remove($StudentNameTextBox)

         $InstructorListLabel.Location  = New-Object System.Drawing.Point(20,70)

         $InstructorListTextBox.Location  = New-Object System.Drawing.Point(20, 95)

   
       
            
        })

    #Create student folders button
    $CreateFoldersButton = New-Object System.Windows.Forms.Button
    $CreateFoldersButton.Text = 'Create Student Folders'
    $CreateFoldersButton.AutoSize = $true
    $CreateFoldersButton.Location = New-Object System.Drawing.Point(30,300)
    $CreateFoldersButton.Add_Click({ CreateFolders ($ClassPathTextBox.Text+$ClassNameTextBox.Text) $StudentListTextBox.Text  $StudentNameTextBox.Text})
   


    #Create instructor folder button
    $CreateInstructorFolderButton = New-Object System.Windows.Forms.Button
    $CreateInstructorFolderButton.Text = 'Add instructor'
    $CreateInstructorFolderButton.AutoSize = $true
    $CreateInstructorFolderButton.Location = New-Object System.Drawing.Point(30,300)
    $CreateInstructorFolderButton.Add_Click({CreateInstructorFolder ($ClassPathTextBox.Text+$ClassNameTextBox.Text+'\') $InstructorListTextBox.Text  $InstructorNameTextBox.Text})
   
   

    #Assign instructor rights button
    $FullProcessButton = New-Object System.Windows.Forms.Button
    $FullProcessButton.Text = 'Full Process'
    $FullProcessButton.AutoSize = $true
    $FullProcessButton.Location = New-Object System.Drawing.Point(30,300)
    $FullProcessButton.Add_Click({FullProcess $ClassPathTextBox $ClassNameTextBox $StudentListTextBox $InstructorListTextBox $StudentNameTextBox.Text})
   


   

    #condition to display button

       $RadioButton1.Add_Click({
        $window_form.Controls.Remove($CreateInstructorFolderButton)
         $window_form.Controls.Remove($CreateFoldersButton)
        $window_form.Controls.Add($FullProcessButton)
       })

        $RadioButton2.Add_Click({
        $window_form.Controls.Remove($FullProcessButton)
        $window_form.Controls.Remove($CreateInstructorFolderButton)
         $window_form.Controls.Add($CreateFoldersButton)
        })

          $RadioButton3.Add_Click({
          $window_form.Controls.Remove($FullProcessButton)
        $window_form.Controls.Remove($CreateFoldersButton)
         $window_form.Controls.Add($CreateInstructorFolderButton)
        })



    $window_form.ShowDialog()
}


CreateInterface


# SIG # Begin signature block
# MIIFlQYJKoZIhvcNAQcCoIIFhjCCBYICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTxL8iCSdvNo0XObbdQWsilJ0
# E56gggMtMIIDKTCCAhGgAwIBAgIQExDB+e9zK45LjlQvUChjrTANBgkqhkiG9w0B
# AQsFADAdMRswGQYDVQQDDBJqbm93bGluQGFzdGF0ZS5lZHUwHhcNMjAwOTEzMDQ1
# MzA1WhcNMjEwOTEzMDUxMzA1WjAdMRswGQYDVQQDDBJqbm93bGluQGFzdGF0ZS5l
# ZHUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCxM377DkwSpjMbxYQR
# zniXhRLlid0Bjt+NLK3xPjAkJKiOSho6M7ExWD6vw4Qfed3FnMEMGzdNJD2rZR9S
# O9cE3JAgxDD6GlPDkiFIYY73VkyUULgg2985Kkk0JSaP9W8zA0ATvYcjGkmLdZWs
# SVaywKVZlT16xpWs4cb91Yvv5A9zWx6TQJqnU9emRXdjHx31wr+sZ2gmoVvSBBHr
# VKSEt1HmzjQC4gDCgEOGMVmifN9FXwPFO9GYrH8ttaAhLX4Kas65Nz5fWMfASpt8
# L/lXNNXxfkZYSstULMPGIJcSceBZ9t3Vb0fvXePPtyRhkvzt6DUsd6Dyo0M9h3Ys
# 8DeVAgMBAAGjZTBjMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcD
# AzAdBgNVHREEFjAUghJqbm93bGluQGFzdGF0ZS5lZHUwHQYDVR0OBBYEFOSxc0bf
# WUz7tgIpWlfGsJIX31ZNMA0GCSqGSIb3DQEBCwUAA4IBAQBrSks6thep7IUmpBz/
# JysfKV9wSNNB60QXmVc2LGA1yEzPMpQrgw0IZE7fczsPD7UK6Q87tSf4FLo0jWtP
# Oj5Kkz7dBEA8qhw0X/UM5o2CKKMTIoIxL6wocgprRlsSzBN9NgMW1QTPW11+c78i
# ZOkuFHUGJMsBhCyCpw+amzZ6WoNYfXiJK7VPlNJtK4piY5mJLusWIWuVObwbMgxV
# qN023ksHthPpXPJEpuZ60jU8OuFhUSCduBxI2r3DH9RBBrlI7ZlP8KxcVOOpaoJS
# szDTj8hYmOtQzVng1OeWLcWrfzDwvU19H32ulvflGGE/HACXB+lAkYig2VoBYxnq
# iVANMYIB0jCCAc4CAQEwMTAdMRswGQYDVQQDDBJqbm93bGluQGFzdGF0ZS5lZHUC
# EBMQwfnvcyuOS45UL1AoY60wCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAI
# oAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIB
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFFAtJjwg4fdOKAcmoaTV
# 00k5D0zYMA0GCSqGSIb3DQEBAQUABIIBAHvK831ynXtMiL935LF4Ez2OBuyiRL8J
# OSBM0FDSOeMVtC9siM++wmx8KJvAblDlx1sfcl42JPzHTL0oHE1P39wurSp6NanA
# /ES6t+ZrCqTofDOLyVV9skoZFrDojOTdQsde6MvbIx5kfwbPzHt/DznNPg9L+id+
# QVQlznIlDgcBW151RTH2NX1t+AFbasCMXF5NCpzdS9UJGosJFs3DmyNt1wsYJeRP
# 6ZHuHEKySYI93uJe4heFMkccBf30ShfXVAOQMSToAMDm/xjwuXstpe7JWi7ADUbx
# ugDag10NEP2sK8g7Zntrp25YT69wV7mh4IevsTu4p/wxSweB9ljTSjk=
# SIG # End signature block
