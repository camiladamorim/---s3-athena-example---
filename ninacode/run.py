from decouple import config
from pipelines.jurimetria import JurimetriaPipeline


def main():

    # Pipeline parameters
    input_filepath = config('INPUT_FILEPATH')
    output_filepath = config('OUTPUT_FILEPATH')

    # Steps parameters
    path_whitelist = config(
        'PATH_WHITELIST',
        default='pipelines/jurimetria/data/whitelist.csv'
    )
    path_lista_advogados = config(
        'PATH_LISTA_ADVOGADOS',
        default='pipelines/jurimetria/data/lista_advogados.csv'
    )
    path_classe_cnj_cliente = config(
        'PATH_CLASSE_CNJ_CLIENTE',
        default='pipelines/jurimetria/data/classe_cnj_cliente.csv'
    )

    with JurimetriaPipeline(input_filepath, output_filepath) as pipeline:
        pipeline.run(
            path_whitelist=path_whitelist,
            path_lista_advogados=path_lista_advogados,
            path_classe_cnj_cliente=path_classe_cnj_cliente
        )


if __name__ == '__main__':
    main()
