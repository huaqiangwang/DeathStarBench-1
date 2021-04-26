import logging

logger = logging.getLogger()


def init():
    logging.basicConfig(level=logging.DEBUG)

    handler = logging.FileHandler('deathstarbench-evaluate.log')
    formatter = logging.Formatter('%(asctime)s: %(name)s '
                                  '- %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    handler.setLevel(logging.DEBUG)
    logger.addHandler(handler)
