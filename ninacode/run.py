from decouple import config
from ninacode.variaveis import Pipeline

def main():

#parameters
    path_whitelist = config('PATH_DATA', default='data/student.csv')

    with Pipeline(path_whitelist) as pipeline:
        pipeline.run()



if __name__ == '__main__':
    main()
