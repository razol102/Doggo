from src.utils.logger import logger
from enum import Enum, auto


# For BCS calculation
class ConditionCategory(Enum):
    EMACIATED = auto()
    VERY_THIN = auto()
    THIN = auto()
    IDEAL = auto()
    OVERWEIGHT = auto()
    OBESE = auto()
    VERY_OBESE = auto()
    SEVERELY_OBESE = auto()
    EXTREMELY_OBESE = auto()


class BCSValue(Enum):
    EMACIATED = 1
    VERY_THIN = 2
    THIN = 3
    IDEAL = 4
    OVERWEIGHT = 5
    OBESE = 6
    VERY_OBESE = 7
    SEVERELY_OBESE = 8
    EXTREMELY_OBESE = 9


THRESHOLDS = {
    ConditionCategory.EMACIATED: 0.4,
    ConditionCategory.VERY_THIN: 0.5,
    ConditionCategory.THIN: 0.6,
    ConditionCategory.IDEAL: 0.7,
    ConditionCategory.OVERWEIGHT: 0.8,
    ConditionCategory.OBESE: 0.9,
    ConditionCategory.VERY_OBESE: 1.0,
    ConditionCategory.SEVERELY_OBESE: 1.1,
    ConditionCategory.EXTREMELY_OBESE: 1.2
}


# Steps length ranges in cm
TOY_DOG_STEP_LENGTH = (25, 35)
SMALL_DOG_STEP_LENGTH = (35, 45)
MEDIUM_DOG_STEP_LENGTH = (45, 55)
LARGE_DOG_STEP_LENGTH = (55, 65)
EXTRA_LARGE_DOG_STEP_LENGTH = (65, 80)

# Weight ranges
TOY_DOG_WEIGHT = (2, 5)
SMALL_DOG_WEIGHT = (5, 10)
MEDIUM_DOG_WEIGHT = (10, 25)
LARGE_DOG_WEIGHT = (25, 40)
EXTRA_LARGE_DOG_WEIGHT = (40, 80)

# Factor ranges
TOY_DOG_FACTOR = (0.5, 0.7)
SMALL_DOG_FACTOR = (0.7, 0.9)
MEDIUM_DOG_FACTOR = (0.9, 1.1)
LARGE_DOG_FACTOR = (1.1, 1.3)
EXTRA_LARGE_DOG_FACTOR = (1.3, 1.6)

METABOLIC_SCALING_EXPONENT = 0.75
HOURS_IN_A_DAY = 24
AVERAGE_WEIGHT = 30  # Average weight in kg
AVERAGE_HEIGHT = 50  # Average height in cm


HEIGHT_RANGES = {
    'TOY_DOG': (0, 25),         # Up to 25 cm
    'SMALL_DOG': (25, 35),      # 25 to 35 cm
    'MEDIUM_DOG': (35, 50),     # 35 to 50 cm
    'LARGE_DOG': (50, 70),      # 50 to 70 cm
    'EXTRA_LARGE_DOG': (70, 100)  # More than 70 cm
}

STEP_LENGTH_RANGES = {
    'TOY_DOG': (25, 35),
    'SMALL_DOG': (35, 45),
    'MEDIUM_DOG': (45, 55),
    'LARGE_DOG': (55, 65),
    'EXTRA_LARGE_DOG': (65, 80)
}


def get_dog_weight_range(weight):
    if TOY_DOG_WEIGHT[0] <= weight <= TOY_DOG_WEIGHT[1]:
        return TOY_DOG_WEIGHT
    elif SMALL_DOG_WEIGHT[0] <= weight <= SMALL_DOG_WEIGHT[1]:
        return SMALL_DOG_WEIGHT
    elif MEDIUM_DOG_WEIGHT[0] <= weight <= MEDIUM_DOG_WEIGHT[1]:
        return MEDIUM_DOG_WEIGHT
    elif LARGE_DOG_WEIGHT[0] <= weight <= LARGE_DOG_WEIGHT[1]:
        return LARGE_DOG_WEIGHT
    elif EXTRA_LARGE_DOG_WEIGHT[0] <= weight <= EXTRA_LARGE_DOG_WEIGHT[1]:
        return EXTRA_LARGE_DOG_WEIGHT
    else:
        return MEDIUM_DOG_FACTOR, MEDIUM_DOG_WEIGHT, MEDIUM_DOG_STEP_LENGTH


def get_dog_factor_range(weight):
    if TOY_DOG_WEIGHT[0] <= weight <= TOY_DOG_WEIGHT[1]:
        return TOY_DOG_FACTOR
    elif SMALL_DOG_WEIGHT[0] <= weight <= SMALL_DOG_WEIGHT[1]:
        return SMALL_DOG_FACTOR
    elif MEDIUM_DOG_WEIGHT[0] <= weight <= MEDIUM_DOG_WEIGHT[1]:
        return MEDIUM_DOG_FACTOR
    elif LARGE_DOG_WEIGHT[0] <= weight <= LARGE_DOG_WEIGHT[1]:
        return LARGE_DOG_FACTOR
    elif EXTRA_LARGE_DOG_WEIGHT[0] <= weight <= EXTRA_LARGE_DOG_WEIGHT[1]:
        return EXTRA_LARGE_DOG_FACTOR
    else:
        return MEDIUM_DOG_FACTOR


def get_position_in_range(weight, weight_range):
    start, end = weight_range
    return (weight - start) / (end - start)


def number_in_range(fraction, range_tuple):
    start, end = range_tuple
    if not (0 <= fraction <= 1):
        raise ValueError("Fraction must be between 0 and 1.")
    return start + fraction * (end - start)


def get_converted_steps(weight, steps_to_convert):
    factor_range = get_dog_factor_range(weight)
    weight_range = get_dog_weight_range(weight)
    fraction = get_position_in_range(weight, weight_range)
    converted_steps = steps_to_convert * number_in_range(fraction, factor_range)

    return converted_steps


def get_calculated_distance(steps, height):
    size_category = determine_size_category_by_height(height)
    average_step_length_cm = calculate_average_step_length(size_category)
    distance_cm = steps * average_step_length_cm
    distance_km = distance_cm / 100000  # Convert cm to km

    return distance_km


def get_burned_calories(weight, distance):
    factor_range = get_dog_factor_range(weight)
    weight_range = get_dog_weight_range(weight)

    fraction = get_position_in_range(weight, weight_range)
    calculated_activity_factor = number_in_range(fraction, factor_range)

    # Estimating BMR (Basal Metabolic Rate) for the dog
    bmr = 70 * (weight ** METABOLIC_SCALING_EXPONENT)

    calories_burned = bmr * calculated_activity_factor * distance / HOURS_IN_A_DAY

    return calories_burned


    # # Constants
    # CALORIES_PER_KG_PER_KM = 1.0  # Approximate calories burned per kg per km
    #
    # # 1. Calculate BMR (Basal Metabolic Rate) - Simplified formula
    # bmr = 70 * (weight ** 0.75)
    #
    # # 2. Calculate calories burned during exercise
    # # Assuming average distance is provided in kilometers
    # calories_burned_exercise = weight * distance * CALORIES_PER_KG_PER_KM
    #
    # # 3. Total Daily Energy Expenditure (TDEE)
    # # if distance <= 0.05:
    # #     tdee = 0
    # # else:
    # tdee = bmr + calories_burned_exercise


def estimate_bcs(weight, height):
    height_m = height / 100

    # Example formula (for demonstration purposes only)
    bcs = (weight / (height_m ** 2)) * 0.1  # This is a placeholder

    # Ensure BCS is within a reasonable range, for instance between 1 and 9
    bcs = max(1, min(bcs, 9))

    return bcs


    # weight_to_height_ratio = weight / height
    #
    # # If the ratio is above the highest threshold, return morbidly obese
    # bcs = BCSValue.EXTREMELY_OBESE.value
    # print(weight_to_height_ratio)
    # # Determine BCS based on thresholds
    # for category, threshold in THRESHOLDS.items():
    #     if weight_to_height_ratio < threshold:
    #         bcs = BCSValue[category.name].value
    #         break
    #
    # return bcs


def calculate_average_step_length(size_category):
    step_length_range = STEP_LENGTH_RANGES[size_category]
    average_step_length_cm = (step_length_range[0] + step_length_range[1]) / 2

    return average_step_length_cm


def determine_size_category_by_height(height_cm):
    for category, (min_height, max_height) in HEIGHT_RANGES.items():
        if min_height <= height_cm <= max_height:
            return category

