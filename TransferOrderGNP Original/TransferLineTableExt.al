tableextension 50100 "Transfer Line Extension" extends "Transfer Line"
{
    fields
    {
        // Unit Price Excl./Incl. VAT
        field(50100; "Unit Price Excl./Incl. VAT"; Decimal)
        {
            Caption = 'Unit Price Excl./Incl. VAT';
            Description = 'Shows the Unit Price from the Default Sales Price List or Item Card';
            Editable = false;
        }

        // Line Amount Excl./Incl. VAT
        field(50101; "Line Amount Excl./Incl. VAT"; Decimal)
        {
            Caption = 'Line Amount Excl./Incl. VAT';
            Description = 'Unit Price Excl./Incl. VAT multiplied by Quantity';
            Editable = false;
        }

        // Confirmed Line Amount Excl./Incl. VAT
        field(50102; "Confirmed Line Amount Excl./Incl. VAT"; Decimal)
        {
            Caption = 'Confirmed Line Amount Excl./Incl. VAT';
            Description = 'Unit Price Excl./Incl. VAT multiplied by Quantity Received';
            Editable = false;
        }

        // Total Amount to Deliver
        field(50103; "Total Amount to Deliver"; Decimal)
        {
            Caption = 'Total Amount to Deliver';
            Description = 'Sum of all Line Amount Excl./Incl. VAT in the Lines FastTab';
            Editable = false;
        }

        // Total Amount Confirmed
        field(50104; "Total Amount Confirmed"; Decimal)
        {
            Caption = 'Total Amount Confirmed';
            Description = 'Sum of all Confirmed Line Amount Excl./Incl. VAT in the Lines FastTab';
            Editable = false;
        }
    }
}
