from src.utils.logger import logger

TOY_DOG_STEP_LENGTH = (25, 35)
SMALL_DOG_STEP_LENGTH = (35, 45)
MEDIUM_DOG_STEP_LENGTH = (45, 55)
LARGE_DOG_STEP_LENGTH = (55, 65)
EXTRA_LARGE_DOG_STEP_LENGTH = (65, 80)

TOY_DOG_WEIGHT = (2, 5)
SMALL_DOG_WEIGHT = (5, 10)
MEDIUM_DOG_WEIGHT = (10, 25)
LARGE_DOG_WEIGHT = (25, 40)
EXTRA_LARGE_DOG_WEIGHT = (40, 80)

TOY_DOG_FACTOR = (0.5, 0.7)
SMALL_DOG_FACTOR = (0.7, 0.9)
MEDIUM_DOG_FACTOR = (0.9, 1.1)
LARGE_DOG_FACTOR = (1.1, 1.3)
EXTRA_LARGE_DOG_FACTOR = (1.3, 1.6)


def get_ranges_by_weight(weight):
    if TOY_DOG_WEIGHT[0] <= weight <= TOY_DOG_WEIGHT[1]:
        return TOY_DOG_FACTOR, TOY_DOG_WEIGHT, TOY_DOG_STEP_LENGTH
    elif SMALL_DOG_WEIGHT[0] <= weight <= SMALL_DOG_WEIGHT[1]:
        return SMALL_DOG_FACTOR, SMALL_DOG_WEIGHT, SMALL_DOG_STEP_LENGTH
    elif MEDIUM_DOG_WEIGHT[0] <= weight <= MEDIUM_DOG_WEIGHT[1]:
        return MEDIUM_DOG_FACTOR, MEDIUM_DOG_WEIGHT, MEDIUM_DOG_STEP_LENGTH
    elif LARGE_DOG_WEIGHT[0] <= weight <= LARGE_DOG_WEIGHT[1]:
        return LARGE_DOG_FACTOR, LARGE_DOG_WEIGHT, LARGE_DOG_STEP_LENGTH
    elif EXTRA_LARGE_DOG_WEIGHT[0] <= weight <= EXTRA_LARGE_DOG_WEIGHT[1]:
        return EXTRA_LARGE_DOG_FACTOR, EXTRA_LARGE_DOG_WEIGHT, EXTRA_LARGE_DOG_STEP_LENGTH
    else:
        return MEDIUM_DOG_FACTOR, MEDIUM_DOG_WEIGHT, MEDIUM_DOG_STEP_LENGTH


def get_position_in_range(weight, weight_range):
    start, end = weight_range
    return (weight - start) / (end - start)


def number_in_range(fraction, range_tuple):
    start, end = range_tuple
    if not (0 <= fraction <= 1):
        raise ValueError("Fraction must be between 0 and 1.")
    return start + fraction * (end - start)


def get_fixed_steps_and_distance(weight, embedded_steps):
    factor_range, weight_range, step_length_range = get_ranges_by_weight(weight)
    fraction = get_position_in_range(weight, weight_range)
    fixed_steps = embedded_steps * number_in_range(fraction, factor_range)
    fixed_distance_cm = fixed_steps * number_in_range(fraction, step_length_range)
    fixed_distance_km = fixed_distance_cm / 100000  # Convert to kilometers

    return fixed_steps, fixed_distance_km


def get_burned_calories(weight, distance):
    logger.debug("Weight: {0}, distance: {1}".format(weight, distance))

    # Constants
    CALORIES_PER_KG_PER_KM = 1.0  # Approximate calories burned per kg per km

    # 1. Calculate BMR (Basal Metabolic Rate) - Simplified formula
    bmr = 70 * (weight ** 0.75)

    # 2. Calculate calories burned during exercise
    # Assuming average distance is provided in kilometers
    calories_burned_exercise = weight * distance * CALORIES_PER_KG_PER_KM

    # 3. Total Daily Energy Expenditure (TDEE)
    if distance <= 0.05:
        tdee = 0
    else:
        tdee = bmr + calories_burned_exercise

    return tdee
