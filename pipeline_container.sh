#!/bin/bash
#write by fullblossom
#version2.0-2018-01-31

#环境初始化
source /etc/profile
mkdir -p /root/rna-process/{reads,index,output-tophat,output-cufflinks,output-cuffmerge,output-cuffquant,output-cuffnorm,output-cuffdiff}

#step1:格式转换sra-to-fastq
fastq-dump -split-3 /root/rna-process/reads/SRR446041.sra && fastq-dump -split-3 /root/rna-process/reads/SRR446042.sra
if [ $? -eq 0 ];then
    echo "convert sucessfull~~"
else 
    echo "convert failed!!pleas check the reads!!"
fi

#step2:tophat2进行比对
tophat2 -p 8 -G /root/rna-process/index/ninanjie.gtf -o /root/rna-process/output-tophat/tophat_SRR446041 /root/rna-process/index/ninanjie  /root/rna-process/reads/SRR446041_1.fastq /root/rna-process/reads/SRR446041_2.fastq 
tophat2 -p 8 -G /root/rna-process/index/ninanjie.gtf -o /root/rna-process/output-tophat/tophat_SRR446042 /root/rna-process/index/ninanjie  /root/rna-process/reads/SRR446042_1.fastq /root/rna-process/reads/SRR446042_2.fastq
tophat2 -p 8 -G /root/rna-process/index/ninanjie.gtf -o /root/rna-process/output-tophat/tophat_SRR446038 /root/rna-process/index/ninanjie  /root/rna-process/reads/SRR446038_1.fastq /root/rna-process/reads/SRR446038_2.fastq

#step3:cufflinks
cufflinks -p 8 -o /root/rna-process/output-cufflinks/cufflinks-SRR446041 /root/rna-process/output-tophat/tophat_SRR446041/accepted_hits.bam 
cufflinks -p 8 -o /root/rna-process/output-cufflinks/cufflinks-SRR446042 /root/rna-process/output-tophat/tophat_SRR446042/accepted_hits.bam
cufflinks -p 8 -o /root/rna-process/output-cufflinks/cufflinks-SRR446038 /root/rna-process/output-tophat/tophat_SRR446038/accepted_hits.bam

#step4:import the reads list to assemblies.txt
echo -e "/root/rna-process/output-cufflinks/cufflinks-SRR446038/transcripts.gtf" >>/root/rna-process/output-cuffmerge/assemblies.txt
echo -e "/root/rna-process/output-cufflinks/cufflinks-SRR446041/transcripts.gtf" >> /root/rna-process/output-cuffmerge/assemblies.txt
echo -e "/root/rna-process/output-cufflinks/cufflinks-SRR446042/transcripts.gtf" >> /root/rna-process/output-cuffmerge/assemblies.txt

#step5:cuffmerge
cuffmerge -p 8 -o /root/rna-process/output-cuffmerge  /root/rna-process/output-cuffmerge/assemblies.txt

#step6:cuffquant
cuffquant -p 8 -o /root/rna-process/output-cuffquant/cuffquant-SRR446038 -b /root/rna-process/index/ninanjie.fa -u /root/rna-process/index/ninanjie.gtf /root/rna-process/output-tophat/tophat_SRR446038/accepted_hits.bam
cuffquant -p 8 -o /root/rna-process/output-cuffquant/cuffquant-SRR446041 -b /root/rna-process/index/ninanjie.fa -u /root/rna-process/index/ninanjie.gtf /root/rna-process/output-tophat/tophat_SRR446041/accepted_hits.bam
cuffquant -p 8 -o /root/rna-process/output-cuffquant/cuffquant-SRR446042 -b /root/rna-process/index/ninanjie.fa -u /root/rna-process/index/ninanjie.gtf /root/rna-process/output-tophat/tophat_SRR446042/accepted_hits.bam
#step7:cuffnorm
cuffnorm -p 8 -o /root/rna-process/output-cuffnorm -L Vir.6h.B,Avr.12h.A,Avr.12h.B /root/rna-process/index/ninanjie.gtf /root/rna-process/output-cuffquant/cuffquant-SRR446038/abundances.cxb /root/rna-process/output-cuffquant/cuffquant-SRR446041/abundances.cxb /root/rna-process/output-cuffquant/cuffquant-SRR446041/abundances.cxb

#step8:cuffdiff
cuffdiff -p 8 -o /root/rna-process/output-cuffdiff/ -b /root/rna-process/index/ninanjie.fa -L Vir.6h.B,Avr.12h.A,Avr.12h.B -u /root/rna-process/output-cuffmerge/merged.gtf /root/rna-process/output-tophat/tophat_SRR446038/accepted_hits.bam /root/rna-process/output-tophat/tophat_SRR446041/accepted_hits.bam /root/rna-process/output-tophat/tophat_SRR446042/accepted_hits.bam
