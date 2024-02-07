process XENIUMRANGER_RESEGMENT {
    tag "$meta.id"
    label 'process_high'

    // container "docker.io/johnyaku/xeniumranger:1.6.0"

    input:
    path xenium_path

    output:
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "XENIUMRANGER_RESEGMENT module does not support Conda. Please use Docker / Singularity / Podman instead."
    }
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    xeniumranger resegment \\
        --id=${meta.id} \\
        --xenium-bundle=${xenium_path} \\
        --expansion-distance=${exp_distance} \\
        --resegment-nuclei=${resegment_nuclei}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        xeniumranger: \$(xeniumranger -V | sed -e "s/xeniumranger xeniumranger-//g")
    END_VERSIONS
    """

    stub:
    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "XENIUMRANGER_RESEGMENT module does not support Conda. Please use Docker / Singularity / Podman instead."
    }
    """
    mkdir -p outs/
    touch outs/fake_file.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        xeniumranger: \$(xeniumranger -V | sed -e "s/xeniumranger xeniumranger-//g")
    END_VERSIONS
    """
}