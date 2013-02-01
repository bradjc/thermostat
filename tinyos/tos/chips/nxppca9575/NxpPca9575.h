#ifndef __NXPPCA9575_H__
#define __NXPPCA9575_H__

typedef struct nxppca9575_config {
	uint8_t polarity_inversion_port0;
	uint8_t polarity_inversion_port1;
	uint8_t bushold_pullupdown_port0;
	uint8_t bushold_pullupdown_port1;
	uint8_t enable_pullupdown_port0;
	uint8_t enable_pullupdown_port1;
	uint8_t pin_direction_port0;
	uint8_t pin_direction_port1;
	uint8_t interrupt_mask_port0;
	uint8_t interrupt_mask_port1;
} nxppca9575_config_t;


#endif
