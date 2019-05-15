import {calculator} from "../src/index";
import {expect} from "chai";

describe("index", () => {
    it('should log first 5 digits of PI', () => {
        // Arrange
        const digits = 5;
        let output = '';
        const logger = {
            write: (digit: any) => output += digit.toString()
        };

        // Act
        calculator(logger as any, digits);


        // Assert
        expect(output).to.eq('31415');
    });
});
