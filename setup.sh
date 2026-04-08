#!/usr/bin/env bash
#
# Divbrowse data setup script
#
# Environment variables:
#   VCF_URL       - URL to download VCF file (required)
#   GFF3_URL      - URL to download GFF3 file (required)
#   CHROM_PATTERN - Regex to filter chromosomes (optional)
#   BASE_URL      - Base URL for the Divbrowse instance (optional)
#
# Example:
#   VCF_URL="https://example.com/variants.vcf.gz" \
#   GFF3_URL="https://example.com/genes.gff3.gz" \
#   ./setup.sh

set -e

# Activate conda environment (works in Docker or local)
if [ -f /opt/conda/etc/profile.d/conda.sh ]; then
    source /opt/conda/etc/profile.d/conda.sh
    conda activate divbrowse_dev
elif [ -f /home/$USER/miniconda3/bin/activate ]; then
    source /home/$USER/miniconda3/bin/activate
    conda activate divbrowse_dev
elif command -v conda &> /dev/null; then
    conda activate divbrowse_dev 2>/dev/null || true
fi

# Check required environment variables
if [ -z "$VCF_URL" ]; then
    echo "ERROR: VCF_URL environment variable is required"
    echo "Example: VCF_URL=https://example.com/variants.vcf.gz ./setup.sh"
    exit 1
fi

if [ -z "$GFF3_URL" ]; then
    echo "ERROR: GFF3_URL environment variable is required"
    echo "Example: GFF3_URL=https://example.com/genes.gff3.gz ./setup.sh"
    exit 1
fi

echo "=== Divbrowse Setup ==="
echo "VCF_URL:  $VCF_URL"
echo "GFF3_URL: $GFF3_URL"
echo ""

# Download GFF3
echo "Downloading GFF3 annotations..."
if [[ "$GFF3_URL" == *.gz ]]; then
    wget -q --show-progress -O genes.gff3.gz "$GFF3_URL"
    gzip -df genes.gff3.gz
else
    wget -q --show-progress -O genes.gff3 "$GFF3_URL"
fi

# Download VCF
echo "Downloading VCF file..."
if [[ "$VCF_URL" == *.vcf.gz ]]; then
    wget -q --show-progress -O variants.vcf.gz "$VCF_URL"
elif [[ "$VCF_URL" == *.vcf ]]; then
    wget -q --show-progress -O variants.vcf "$VCF_URL"
    bgzip variants.vcf
else
    wget -q --show-progress -O variants.vcf.gz "$VCF_URL"
fi

# Index and extract chromosome list
echo "Indexing VCF..."
tabix -f variants.vcf.gz

# Get chromosomes (filter to likely main chromosomes, exclude scaffolds/contigs if pattern provided)
echo "Extracting chromosome list..."
if [ -n "$CHROM_PATTERN" ]; then
    tabix -l variants.vcf.gz | grep -E "$CHROM_PATTERN" > chromosomes.txt
else
    # Use all chromosomes
    tabix -l variants.vcf.gz > chromosomes.txt
fi

# Filter VCF to selected chromosomes (if pattern was provided)
if [ -n "$CHROM_PATTERN" ]; then
    echo "Filtering VCF to selected chromosomes..."
    CHROMS=$(cat chromosomes.txt | tr '\n' ',' | sed 's/,$//')
    bcftools view -r "$CHROMS" variants.vcf.gz -Oz -o variants_filtered.vcf.gz
    mv variants_filtered.vcf.gz variants.vcf.gz
    tabix -f variants.vcf.gz
fi

# Convert VCF to Zarr
echo "Converting VCF to Zarr format (this may take a while)..."
divbrowse vcf2zarr --path-vcf variants.vcf.gz --path-zarr variants.zarr

# Generate chromosome labels from the Zarr
echo "Generating configuration..."
python3 << 'PYSCRIPT'
import os
import zarr
import yaml

# Read chromosomes from Zarr
callset = zarr.open_group('variants.zarr', mode='r')
chromosomes = list(dict.fromkeys(callset['variants/CHROM'][:]))  # unique, preserve order

# Build chromosome label mappings (identity mapping by default)
chrom_labels = {str(c): str(c) for c in chromosomes}
centromere_positions = {str(c): 0 for c in chromosomes}

config = {
    'metadata': {
        'general_description': '',
        'vcf_doi': '',
        'vcf_reference_genome_doi': '',
        'gff3_doi': '',
    },
    'datadir': './',
    'base_url': os.environ.get('BASE_URL', ''),
    'variants': {
        'zarr_dir': 'variants.zarr',
        'sample_id_mapping_filename': '',
    },
    'gff3': {
        'filename': 'genes.gff3',
        'additional_attributes_keys': 'biotype,gene_id',
        'feature_type_with_description': 'gene',
        'count_exon_variants': False,
        'key_confidence': False,
        'key_ontology': 'Ontology_term',
        'main_feature_types_for_genes_track': ['gene'],
        'external_link_ontology_term': 'https://www.ebi.ac.uk/QuickGO/term/{ID}',
        'external_links': None,
    },
    'features': {
        'pca': True,
        'umap': True,
    },
    'chromosome_labels': chrom_labels,
    'gff3_chromosome_labels': chrom_labels.copy(),
    'centromeres_positions': centromere_positions,
    'blast': {
        'active': False,
        'galaxy_server_url': '',
        'galaxy_apikey': '',
        'galaxy_user': '',
        'galaxy_pass': '',
        'blastn': {
            'galaxy_tool_id': '',
            'blast_database': '',
            'blast_type': '',
        },
        'tblastn': {
            'galaxy_tool_id': '',
            'blast_database': '',
            'blast_type': '',
        },
        'blast_result_to_vcf_chromosome_mapping': None,
    },
    'brapi': {
        'active': False,
        'commoncropname': '',
        'serverinfo': {
            'server_name': '',
            'server_description': '',
            'organization_name': '',
            'organization_url': '',
            'location': '',
            'contact_email': '',
            'documentation_url': '',
        },
    },
    'linkouts': {
        'gene': ['https://services.lis.ncgr.org/gene_linkouts'],
        'genomic_region': ['https://services.lis.ncgr.org/genomic_region_linkouts'],
    },
    'snpeff': {
        'default_color': 'rgb(165,165,165)',
    },
}

with open('divbrowse.config.yml', 'w') as f:
    yaml.dump(config, f, default_flow_style=False, sort_keys=False)

print(f"Configuration generated with {len(chromosomes)} chromosomes")
PYSCRIPT

echo ""
echo "=== Setup Complete ==="
echo "Files created:"
echo "  - variants.zarr/"
echo "  - genes.gff3"
echo "  - divbrowse.config.yml"
