# Divbrowse
Fork with changes; [original README](./README.original.md) / [original source](https://github.com/IPK-BIT/divbrowse)

## Quick Start
First:
1. Set up [miniconda](https://www.anaconda.com/docs/getting-started/miniconda/main)
2. Set up Node with [nvm](https://github.com/nvm-sh/nvm) and install latest LTS (`nvm install --lts`)

### Snp50k
Please see the [setup.sh](./setup.sh) helper script.

### Installation
> [!NOTE]
> The steps below are for local (non-Docker) development. The Docker image builds
> the frontend automatically (see [Dockerfile](./Dockerfile)), so these manual
> `npm`/`cp` steps are not needed when running via Docker.

```bash
git clone https://github.com/legumeinfo/divbrowse
cd divbrowse
mkdir -p divbrowse/static
conda env create -f environment.yml
conda activate divbrowse_dev
cd frontend
npm ci
npm run build
cp dist/divbrowse.js ../divbrowse/static/.
cd ..
pip install -e .
```

### Running
Retrieve VCF and GFF:
```bash
wget https://data.legumeinfo.org/Glycine/max/diversity/Wm82.gnm4.div.Song_Hyten_2015/glyma.Wm82.gnm4.div.Song_Hyten_2015.vcf.gz
wget https://data.legumeinfo.org/Glycine/max/annotations/Wm82.gnm4.ann1.T8TQ/glyma.Wm82.gnm4.ann1.T8TQ.gene_models_main.gff3.gz
gzip -d glyma.Wm82.gnm4.ann1.T8TQ.gene_models_main.gff3.gz
```

Remove scaffolds, include only chromosomes:
```bash
tabix glyma.Wm82.gnm4.div.Song_Hyten_2015.vcf.gz
tabix -l glyma.Wm82.gnm4.div.Song_Hyten_2015.vcf.gz | grep -E "glyma\\.Wm82\\.gnm4\\.Gm[0-9]+" > chromosomes.txt
CHROMS=$(cat chromosomes.txt | tr '\n' ',' | sed 's/,$//')
bcftools view -r "$CHROMS" glyma.Wm82.gnm4.div.Song_Hyten_2015.vcf.gz -Oz -o gnm4.vcf.gz
```

Create zarr:
```bash
divbrowse vcf2zarr --path-vcf gnm4.vcf.gz --path-zarr variants.zarr
```

Create `divbrowse.config.yml` in the same directory with the following contents:
```yaml
metadata:
  general_description: 
  vcf_doi: 
  vcf_reference_genome_doi: 
  gff3_doi: 

datadir: ./

variants:
  zarr_dir: variants.zarr
  sample_id_mapping_filename: 

gff3:
  filename: glyma.Wm82.gnm4.ann1.T8TQ.gene_models_main.gff3
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
  "glyma.Wm82.gnm4.Gm01": "chr1"
  "glyma.Wm82.gnm4.Gm02": "chr2"
  "glyma.Wm82.gnm4.Gm03": "chr3"
  "glyma.Wm82.gnm4.Gm04": "chr4"
  "glyma.Wm82.gnm4.Gm05": "chr5"
  "glyma.Wm82.gnm4.Gm06": "chr6"
  "glyma.Wm82.gnm4.Gm07": "chr7"
  "glyma.Wm82.gnm4.Gm08": "chr8"
  "glyma.Wm82.gnm4.Gm09": "chr9"
  "glyma.Wm82.gnm4.Gm10": "chr10"
  "glyma.Wm82.gnm4.Gm11": "chr11"
  "glyma.Wm82.gnm4.Gm12": "chr12"
  "glyma.Wm82.gnm4.Gm13": "chr13"
  "glyma.Wm82.gnm4.Gm14": "chr14"
  "glyma.Wm82.gnm4.Gm15": "chr15"
  "glyma.Wm82.gnm4.Gm16": "chr16"
  "glyma.Wm82.gnm4.Gm17": "chr17"
  "glyma.Wm82.gnm4.Gm18": "chr18"
  "glyma.Wm82.gnm4.Gm19": "chr19"
  "glyma.Wm82.gnm4.Gm20": "chr20"

gff3_chromosome_labels:
  "glyma.Wm82.gnm4.Gm01": "glyma.Wm82.gnm4.Gm01"
  "glyma.Wm82.gnm4.Gm02": "glyma.Wm82.gnm4.Gm02"
  "glyma.Wm82.gnm4.Gm03": "glyma.Wm82.gnm4.Gm03"
  "glyma.Wm82.gnm4.Gm04": "glyma.Wm82.gnm4.Gm04"
  "glyma.Wm82.gnm4.Gm05": "glyma.Wm82.gnm4.Gm05"
  "glyma.Wm82.gnm4.Gm06": "glyma.Wm82.gnm4.Gm06"
  "glyma.Wm82.gnm4.Gm07": "glyma.Wm82.gnm4.Gm07"
  "glyma.Wm82.gnm4.Gm08": "glyma.Wm82.gnm4.Gm08"
  "glyma.Wm82.gnm4.Gm09": "glyma.Wm82.gnm4.Gm09"
  "glyma.Wm82.gnm4.Gm10": "glyma.Wm82.gnm4.Gm10"
  "glyma.Wm82.gnm4.Gm11": "glyma.Wm82.gnm4.Gm11"
  "glyma.Wm82.gnm4.Gm12": "glyma.Wm82.gnm4.Gm12"
  "glyma.Wm82.gnm4.Gm13": "glyma.Wm82.gnm4.Gm13"
  "glyma.Wm82.gnm4.Gm14": "glyma.Wm82.gnm4.Gm14"
  "glyma.Wm82.gnm4.Gm15": "glyma.Wm82.gnm4.Gm15"
  "glyma.Wm82.gnm4.Gm16": "glyma.Wm82.gnm4.Gm16"
  "glyma.Wm82.gnm4.Gm17": "glyma.Wm82.gnm4.Gm17"
  "glyma.Wm82.gnm4.Gm18": "glyma.Wm82.gnm4.Gm18"
  "glyma.Wm82.gnm4.Gm19": "glyma.Wm82.gnm4.Gm19"
  "glyma.Wm82.gnm4.Gm20": "glyma.Wm82.gnm4.Gm20"

centromeres_positions:
  "glyma.Wm82.gnm4.Gm01": 0
  "glyma.Wm82.gnm4.Gm02": 0
  "glyma.Wm82.gnm4.Gm03": 0
  "glyma.Wm82.gnm4.Gm04": 0
  "glyma.Wm82.gnm4.Gm05": 0
  "glyma.Wm82.gnm4.Gm06": 0
  "glyma.Wm82.gnm4.Gm07": 0
  "glyma.Wm82.gnm4.Gm08": 0
  "glyma.Wm82.gnm4.Gm09": 0
  "glyma.Wm82.gnm4.Gm10": 0
  "glyma.Wm82.gnm4.Gm11": 0
  "glyma.Wm82.gnm4.Gm12": 0
  "glyma.Wm82.gnm4.Gm13": 0
  "glyma.Wm82.gnm4.Gm14": 0
  "glyma.Wm82.gnm4.Gm15": 0
  "glyma.Wm82.gnm4.Gm16": 0
  "glyma.Wm82.gnm4.Gm17": 0
  "glyma.Wm82.gnm4.Gm18": 0
  "glyma.Wm82.gnm4.Gm19": 0
  "glyma.Wm82.gnm4.Gm20": 0

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
```

Run:
```bash
divbrowse start
```