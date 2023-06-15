# README

Because GitHub has a limit of 25MB upload for any given single file, one of the data files, `master_monthly_sst.mat`, was split into 24MB chunks using to the Unix `split` command (use "`man split`" for documentation).

## File size
`303453896 Aug 9 2018    master_monthly_sst.mat`

## MD5SUM
`MD5 (master_monthly_sst.mat) = c8687861dc9ae5bb84280b22aef23e51`

## Restore original file
To join the file back to it's original 303MB size, use the following command:

`cat xaa xab xac xad xae xaf xag xah xai xaj xak xal xam > master_monthly_sst.mat`

## Verify the MD5 checksum
To verify the MD5 checksum of the re-joined file, use the following command:

`md5 master_monthly_sst.mat`
