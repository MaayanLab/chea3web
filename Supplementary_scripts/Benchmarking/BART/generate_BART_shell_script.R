#the purpose of this script is to generate a shell script to run BART
dir1  = "/users/summerstudent/margeoutput_new_job_3/cisRegions/"

filenames = paste(dir1,list.files(dir1),sep = "")
filenames = filenames[grep("enhancer_prediction.txt",filenames)]
outdir = '/users/summerstudent/bart_output/'
dir.create(outdir)


cmds = data.frame(commands = paste('bart geneset -i ',filenames, ' -s hg38 -p 4 --outdir ', outdir, sep = "" ), stringsAsFactors = F)
write.table(cmds,"/users/summerstudent/bart_output/bart_workflow.sh", quote = F, row.names = F, col.names = F)
