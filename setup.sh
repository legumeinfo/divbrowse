#!/usr/bin/env bash

source /home/$USER/miniconda3/bin/activate
conda activate divbrowse_dev

if [ -z "$1" ]; then
  echo "Usage: $0 <GNM>"
  echo "Example: $0 gnm4"
  exit 1
fi

GNM="$1"

# TODO: SnpEff annotations in public VCFs

case "$GNM" in
  gnm1)
    wget -O Wm82.gff3.gz "https://data.legumeinfo.org/Glycine/max/annotations/Wm82.gnm1.ann1.DvBy/glyma.Wm82.gnm1.ann1.DvBy.gene_models_main.gff3.gz"
    #wget -O gnm.vcf.gz "https://data.legumeinfo.org/Glycine/max/diversity/Wm82.gnm1.div.Song_Hyten_2015/glyma.Wm82.gnm1.div.Song_Hyten_2015.vcf.gz"
    ;;
  gnm2)
    wget -O Wm82.gff3.gz "https://data.legumeinfo.org/Glycine/max/annotations/Wm82.gnm2.ann1.RVB6/glyma.Wm82.gnm2.ann1.RVB6.gene_models_main.gff3.gz"
    #wget -O gnm.vcf.gz "https://data.legumeinfo.org/Glycine/max/diversity/Wm82.gnm2.div.Song_Hyten_2015/glyma.Wm82.gnm2.div.Song_Hyten_2015.vcf.gz"
    ;;
  gnm4)
    wget -O Wm82.gff3.gz "https://data.legumeinfo.org/Glycine/max/annotations/Wm82.gnm4.ann1.T8TQ/glyma.Wm82.gnm4.ann1.T8TQ.gene_models_main.gff3.gz"
    #wget -O gnm.vcf.gz "https://data.legumeinfo.org/Glycine/max/diversity/Wm82.gnm4.div.Song_Hyten_2015/glyma.Wm82.gnm4.div.Song_Hyten_2015.vcf.gz"
    ;;
  gnm5)
    wget -O Wm82.gff3.gz "https://data.legumeinfo.org/Glycine/max/annotations/Wm82.gnm5.ann1.J7HW/glyma.Wm82.gnm5.ann1.J7HW.gene_models_main.gff3.gz"
    #wget -O gnm.vcf.gz "https://data.legumeinfo.org/Glycine/max/diversity/Wm82.gnm5.div.Song_Hyten_2015/glyma.Wm82.gnm5.div.Song_Hyten_2015.vcf.gz"
    ;;
  gnm6)
    wget -O Wm82.gff3.gz "https://data.legumeinfo.org/Glycine/max/annotations/Wm82.gnm6.ann1.PKSW/glyma.Wm82.gnm6.ann1.PKSW.gene_models_main.gff3.gz"
    #wget -O gnm.vcf.gz "https://data.legumeinfo.org/Glycine/max/diversity/Wm82.gnm6.div.Song_Hyten_2015/glyma.Wm82.gnm6.div.Song_Hyten_2015.vcf.gz"
    ;;
  *)
    echo "Error: Unknown GNM version '$GNM'"
    echo "Supported versions: gnm1, gnm2, gnm4, gnm5, gnm6"
    exit 1
    ;;
esac

gzip -d Wm82.gff3.gz

tabix gnm.vcf.gz
tabix -l gnm.vcf.gz | grep -E "glyma\\.Wm82\\.${GNM}\\.Gm[0-9]+" > chromosomes.txt
CHROMS=$(cat chromosomes.txt | tr '\n' ',' | sed 's/,$//')
bcftools view -r "$CHROMS" gnm.vcf.gz -Oz -o gnm_chroms.vcf.gz

divbrowse vcf2zarr --path-vcf gnm_chroms.vcf.gz --path-zarr variants.zarr

cat <<EOF > divbrowse.config.yml
metadata:
  general_description: 
  vcf_doi: 
  vcf_reference_genome_doi: 
  gff3_doi: 

datadir: ./

base_url: https://divbrowse.soybase.org/$GNM/

variants:
  zarr_dir: variants.zarr
  sample_id_mapping_filename: 

gff3:
  filename: Wm82.gff3
  additional_attributes_keys: biotype,gene_id
  feature_type_with_description: gene
  count_exon_variants: false
  key_confidence: false
  key_ontology: Ontology_term
  main_feature_types_for_genes_track: 
    - gene
  external_link_ontology_term: https://www.ebi.ac.uk/QuickGO/term/{ID}
  external_links:

features:
  pca: true
  umap: true

chromosome_labels:
  "glyma.Wm82.$GNM.Gm01": "glyma.Wm82.$GNM.Gm01"
  "glyma.Wm82.$GNM.Gm02": "glyma.Wm82.$GNM.Gm02"
  "glyma.Wm82.$GNM.Gm03": "glyma.Wm82.$GNM.Gm03"
  "glyma.Wm82.$GNM.Gm04": "glyma.Wm82.$GNM.Gm04"
  "glyma.Wm82.$GNM.Gm05": "glyma.Wm82.$GNM.Gm05"
  "glyma.Wm82.$GNM.Gm06": "glyma.Wm82.$GNM.Gm06"
  "glyma.Wm82.$GNM.Gm07": "glyma.Wm82.$GNM.Gm07"
  "glyma.Wm82.$GNM.Gm08": "glyma.Wm82.$GNM.Gm08"
  "glyma.Wm82.$GNM.Gm09": "glyma.Wm82.$GNM.Gm09"
  "glyma.Wm82.$GNM.Gm10": "glyma.Wm82.$GNM.Gm10"
  "glyma.Wm82.$GNM.Gm11": "glyma.Wm82.$GNM.Gm11"
  "glyma.Wm82.$GNM.Gm12": "glyma.Wm82.$GNM.Gm12"
  "glyma.Wm82.$GNM.Gm13": "glyma.Wm82.$GNM.Gm13"
  "glyma.Wm82.$GNM.Gm14": "glyma.Wm82.$GNM.Gm14"
  "glyma.Wm82.$GNM.Gm15": "glyma.Wm82.$GNM.Gm15"
  "glyma.Wm82.$GNM.Gm16": "glyma.Wm82.$GNM.Gm16"
  "glyma.Wm82.$GNM.Gm17": "glyma.Wm82.$GNM.Gm17"
  "glyma.Wm82.$GNM.Gm18": "glyma.Wm82.$GNM.Gm18"
  "glyma.Wm82.$GNM.Gm19": "glyma.Wm82.$GNM.Gm19"
  "glyma.Wm82.$GNM.Gm20": "glyma.Wm82.$GNM.Gm20"

gff3_chromosome_labels:
  "glyma.Wm82.$GNM.Gm01": "glyma.Wm82.$GNM.Gm01"
  "glyma.Wm82.$GNM.Gm02": "glyma.Wm82.$GNM.Gm02"
  "glyma.Wm82.$GNM.Gm03": "glyma.Wm82.$GNM.Gm03"
  "glyma.Wm82.$GNM.Gm04": "glyma.Wm82.$GNM.Gm04"
  "glyma.Wm82.$GNM.Gm05": "glyma.Wm82.$GNM.Gm05"
  "glyma.Wm82.$GNM.Gm06": "glyma.Wm82.$GNM.Gm06"
  "glyma.Wm82.$GNM.Gm07": "glyma.Wm82.$GNM.Gm07"
  "glyma.Wm82.$GNM.Gm08": "glyma.Wm82.$GNM.Gm08"
  "glyma.Wm82.$GNM.Gm09": "glyma.Wm82.$GNM.Gm09"
  "glyma.Wm82.$GNM.Gm10": "glyma.Wm82.$GNM.Gm10"
  "glyma.Wm82.$GNM.Gm11": "glyma.Wm82.$GNM.Gm11"
  "glyma.Wm82.$GNM.Gm12": "glyma.Wm82.$GNM.Gm12"
  "glyma.Wm82.$GNM.Gm13": "glyma.Wm82.$GNM.Gm13"
  "glyma.Wm82.$GNM.Gm14": "glyma.Wm82.$GNM.Gm14"
  "glyma.Wm82.$GNM.Gm15": "glyma.Wm82.$GNM.Gm15"
  "glyma.Wm82.$GNM.Gm16": "glyma.Wm82.$GNM.Gm16"
  "glyma.Wm82.$GNM.Gm17": "glyma.Wm82.$GNM.Gm17"
  "glyma.Wm82.$GNM.Gm18": "glyma.Wm82.$GNM.Gm18"
  "glyma.Wm82.$GNM.Gm19": "glyma.Wm82.$GNM.Gm19"
  "glyma.Wm82.$GNM.Gm20": "glyma.Wm82.$GNM.Gm20"

centromeres_positions:
  "glyma.Wm82.$GNM.Gm01": 0
  "glyma.Wm82.$GNM.Gm02": 0
  "glyma.Wm82.$GNM.Gm03": 0
  "glyma.Wm82.$GNM.Gm04": 0
  "glyma.Wm82.$GNM.Gm05": 0
  "glyma.Wm82.$GNM.Gm06": 0
  "glyma.Wm82.$GNM.Gm07": 0
  "glyma.Wm82.$GNM.Gm08": 0
  "glyma.Wm82.$GNM.Gm09": 0
  "glyma.Wm82.$GNM.Gm10": 0
  "glyma.Wm82.$GNM.Gm11": 0
  "glyma.Wm82.$GNM.Gm12": 0
  "glyma.Wm82.$GNM.Gm13": 0
  "glyma.Wm82.$GNM.Gm14": 0
  "glyma.Wm82.$GNM.Gm15": 0
  "glyma.Wm82.$GNM.Gm16": 0
  "glyma.Wm82.$GNM.Gm17": 0
  "glyma.Wm82.$GNM.Gm18": 0
  "glyma.Wm82.$GNM.Gm19": 0
  "glyma.Wm82.$GNM.Gm20": 0

blast:
  active: false
  galaxy_server_url:
  galaxy_apikey:
  galaxy_user:
  galaxy_pass:
  blastn:
    galaxy_tool_id:
    blast_database:
    blast_type:
  tblastn:
    galaxy_tool_id:
    blast_database:
    blast_type:
  blast_result_to_vcf_chromosome_mapping:


brapi:
  active: false
  commoncropname: 
  serverinfo:
    server_name: 
    server_description: 
    organization_name: 
    organization_url: 
    location: 
    contact_email: 
    documentation_url: 

linkouts:
  gene:
    - https://services.lis.ncgr.org/gene_linkouts
  genomic_region:
    - https://services.lis.ncgr.org/genomic_region_linkouts

snpeff:
  default_color: "rgb(165,165,165)" # Gray
EOF
