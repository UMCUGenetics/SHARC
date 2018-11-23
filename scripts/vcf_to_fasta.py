import json, requests
import vcf as pyvcf
import argparse
import sys

server = "https://grch37.rest.ensembl.org"

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser(description='Put here a description.')
parser.add_argument('vcf', help='VCF file')
parser.add_argument('-o', '--offset', default=0, type=int, help='Offset [default: 0]')
parser.add_argument('-f', '--flank', default=200, type=int, help='Flank [default: 200]')
parser.add_argument('-m', '--mask',action='store_true')
args = parser.parse_args()
vcf = args.vcf
offset = args.offset
flank = args.flank
mask = args.mask

def mask_seq( chr, start, end, strand, seq ):
    ext = "/overlap/region/human/"+str(chr)+":"+str(start)+"-"+str(end)+":"+str(strand)+"?feature=variation"

    TRY=1
    while TRY <= 10:
        try:
            request = requests.get(server+ext, headers={ "Content-Type" : "application/json"})
            data = json.loads(request.text)
            break
        except:
            if TRY==10:
                sys.exit("Error while requesting from ENSEMBL database after", TRY,  "tries")
        TRY +=1

    masked_seq = seq

    for snp in data:
        snp_pos= snp['start']-start
        if str(strand) == '-1':
            snp_pos = len(masked_seq)-snp_pos-1
        masked_seq = masked_seq[:snp_pos]+'n'+masked_seq[snp_pos+1:];
    return( masked_seq )


def get_seq(chr, start, end, strand):
    ext = "/info/assembly/homo_sapiens/"+str(chr)
    TRY=1
    while TRY <= 10:
        try:
            request = requests.get(server+ext, headers={ "Content-Type" : "application/json"})
            data = json.loads(request.text)
            break
        except:
            if TRY==10:
                sys.exit("Error while requesting from ENSEMBL database after", TRY,  "tries")
        TRY +=1

    chrlength = data['length']

    ext = "/sequence/region/human/"+str(chr)+":"+str(start)+"-"+str(end)+":"+str(strand)+""
    if start < 1:
        sys.stderr.write("\tFailed to get seq, because POS is too close to START of the chr\n")
        seq = False
    elif end > chrlength:
        sys.stderr.write("\tFailed to get seq, because ENDPOS is too close to END of the chr\n")
        seq = False
    else:
        TRY=1
        while TRY <= 10:
            try:
                request = requests.get(server+ext, headers={ "Content-Type" : "application/json"})
                data = json.loads(request.text)
                break
            except:
                if TRY==10:
                    sys.exit("Error while requesting from ENSEMBL database after", TRY,  "tries")
            TRY +=1
        seq = data['seq']
        if mask:
            seq = mask_seq(chr, start, end, strand, seq )
    return( seq )

# def reverse_complement( seq ):
#     reverse_seq = seq[::-1]
#     complement = {'A':'T', 'C':'G', 'G':'C','T':'A'}
#     bases = list(reverse_seq)
#     bases = [complement.get(base,'n') for base in bases]
#     return( ''.join(bases) )

def alt_convert( record ):
    orientation = None
    remoteOrientation = None
    if record.INFO['SVTYPE'] == 'INS':
        orientation = False
        remoteOrientation = True
    if record.INFO['SVTYPE'] == 'DEL':
        orientation = False
        remoteOrientation = True
    elif record.INFO['SVTYPE'] == 'DUP':
        orientation = True
        remoteOrientation = False
    elif 'INV3' in record.INFO:
    	orientation = False
    	remoteOrientation = False
    elif 'INV5' in record.INFO:
        orientation = True
        remoteOrientation = True
    elif 'STRANDS' in record.INFO:
        if record.INFO['STRANDS'][0] == '++':
            orientation = False
            remoteOrientation = False
        elif record.INFO['STRANDS'][0] == '--':
            orientation = True
            remoteOrientation = True
        elif record.INFO['STRANDS'][0] == '-+':
            orientation = True
            remoteOrientation = False
        elif record.INFO['STRANDS'][0] == '+-':
            orientation = False
            remoteOrientation = True

    if 'CT' in record.INFO:
        if record.INFO['CT'] == '3to5':
            orientation = False
            remoteOrientation = True
        elif record.INFO['CT'] == '3to3':
            orientation = False
            remoteOrientation = False
        elif record.INFO['CT'] == '5to3':
            orientation = True
            remoteOrientation = False
        elif record.INFO['CT'] == '5to5':
            orientation = True
            remoteOrientation = True
    if orientation is None or remoteOrientation is None:
        sys.stderr.write( "\tFailed to convert orientation"+"\n" )
        record = False
    else:
        record.ALT = [ pyvcf.model._Breakend( record.CHROM, record.INFO['END'], orientation, remoteOrientation, record.REF, True ) ]
    return( record )

vcf_reader = pyvcf.Reader(open(vcf, 'r'))
for record in vcf_reader:
    sys.stderr.write( str(record) )
    if isinstance(record.ALT[0], pyvcf.model._SV) or isinstance( record.ALT[0], pyvcf.model._Substitution ):
        record = alt_convert( record )
    if not record:
        continue
    seq1 = ''
    seq2 = ''
    if record.ALT[0].orientation:
        seq1 = get_seq(record.CHROM, record.POS+offset, record.POS+offset+flank, -1)
    else:
        seq1 = get_seq(record.CHROM, record.POS-flank-offset, record.POS-offset, 1)
    if not seq1:
        continue
    if record.ALT[0].remoteOrientation:
        seq2 = get_seq(record.ALT[0].chr, record.ALT[0].pos+offset, record.ALT[0].pos+offset+flank, 1)
    else:
        seq2 = get_seq(record.ALT[0].chr, record.ALT[0].pos-offset-flank, record.ALT[0].pos-offset, -1)
    if not seq2:
        continue
    sys.stderr.write("\tSucces\n")
    print(">"+record.ID)
    print( seq1+"[]"+seq2 )
