tableextension 50101 "Transfer Header Extension" extends "Transfer Header"
{
    fields
    {
        // Total Amount to Deliver
        field(50100; "Total Amount to Deliver"; Decimal)
        {
            Caption = 'Total Amount to Deliver';
            Description = 'Sum of all Line Amount Excl./Incl. VAT in the Lines FastTab';
            Editable = false;
        }

        // Total Amount Confirmed
        field(50101; "Total Amount Confirmed"; Decimal)
        {
            Caption = 'Total Amount Confirmed';
            Description = 'Sum of all Confirmed Line Amount Excl./Incl. VAT in the Lines FastTab';
            Editable = false;
        }
    }
}