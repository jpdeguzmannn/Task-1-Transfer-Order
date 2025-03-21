pageextension 50101 "Transfer Order List Extension" extends "Transfer Orders"
{
    layout
    {
        addafter("Status")
        {
            field("Total Amount to Deliver"; Rec."Total Amount to Deliver")
            {
                ApplicationArea = All;
                Caption = 'Total Amount to Deliver';
                ToolTip = 'Sum of all Line Amount Excl./Incl. VAT in the Lines FastTab';
            }
            field("Total Amount Confirmed"; Rec."Total Amount Confirmed")
            {
                ApplicationArea = All;
                Caption = 'Total Amount Confirmed';
                ToolTip = 'Sum of all Confirmed Line Amount Excl./Incl. VAT in the Lines FastTab';
            }
        }
    }
}
