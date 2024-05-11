process SCSPLIT_RUN {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container 'wxicu/scsplit:1.0.8'

    input:
    tuple val(meta), path(ref), path(alt), val(num), path(vcf)

    output:
    tuple val(meta), path('*_result.csv')       , emit: result
    tuple val(meta), path('*_dist_variants.txt'), emit: dist_variants
    tuple val(meta), path('*_dist_matrix.csv')  , emit: dist_matrix
    tuple val(meta), path('*_PA_matrix.csv')    , emit: alt_allele
    tuple val(meta), path('*_P_s_c.csv')        , emit: probability
    tuple val(meta), path('*_scSplit.log')      , emit: log
    path 'versions.yml'                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def vcf_input = vcf ? "-v ${vcf}" : ''
    def VERSION = '1.0.8' // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.

    """
    if [ -z "${workflow.containerEngine}" ];
        then scsplit_path="scSplit";
    else
        scsplit_path="python \$(python -c 'import site; print("".join(site.getsitepackages()))')/scSplit/scSplit";
    fi
    \$scsplit_path run \\
        -r $ref \\
        -a $alt \\
        -n $num \\
        $vcf_input \\
        -o . \\
        $args

    mv scSplit_result.csv ${prefix}_result.csv
    mv scSplit_dist_variants.txt ${prefix}_dist_variants.txt
    mv scSplit_dist_matrix.csv ${prefix}_dist_matrix.csv
    mv scSplit_PA_matrix.csv ${prefix}_PA_matrix.csv
    mv scSplit_P_s_c.csv ${prefix}_P_s_c.csv
    mv scSplit.log ${prefix}_scSplit.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scsplit: $VERSION
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '1.0.8' // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.

    """
    touch ${prefix}_result.csv
    touch ${prefix}_dist_variants.txt
    touch ${prefix}_dist_matrix.csv
    touch ${prefix}_PA_matrix.csv
    touch ${prefix}_P_s_c.csv
    touch ${prefix}_scSplit.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        scsplit: $VERSION
    END_VERSIONS
    """
}
